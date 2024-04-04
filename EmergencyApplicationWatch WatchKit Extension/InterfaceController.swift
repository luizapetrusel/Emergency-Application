//
//  InterfaceController.swift
//  EmergencyApplicationWatch WatchKit Extension
//
//  Created by Luiza Petrusel on 28.02.2023.
//

import WatchKit
import Foundation
import HealthKit
import SceneKit
import SpriteKit

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var bpmLabel: WKInterfaceLabel!
    @IBOutlet weak var sceneInterface: WKInterfaceSKScene!

    private var workoutSession: HKWorkoutSession?
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKObserverQuery?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.requestAuthorization()

        /// Creating an observer, so updates are received whenever HealthKit’s
        // heart rate data changes.
        guard let sampleType: HKSampleType =
                HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        self.heartRateQuery = HKObserverQuery.init(
            sampleType: sampleType,
            predicate: nil) { [weak self] _, _, error in
                guard error == nil else {
                    print(error!)
                    return
                }

                /// When the completion is called, an other query is executed
                /// to fetch the latest heart rate
                self?.fetchLatestHeartRateSample(completion: { sample in
                    guard let sample = sample else {
                        return
                    }
                    /// Converting the heart rate to bpm
                    let heartRateUnit = HKUnit(from: "count/min")
                    let heartRate = sample
                        .quantity
                        .doubleValue(for: heartRateUnit)

                    /// The completion in called on a background thread, but we
                    /// need to update the UI on the main.
                    DispatchQueue.main.async { [self] in

                        /// Updating the UI with the retrieved value
                        self?.bpmLabel.setText("\(Int(heartRate))")
                    }

                })
            }

        if let query = self.heartRateQuery {
            self.healthStore.execute(query)
        }
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func fetchLatestHeartRateSample(
        completion: @escaping (_ sample: HKQuantitySample?) -> Void) {

            /// Create sample type for the heart rate
            guard let sampleType = HKObjectType
                .quantityType(forIdentifier: .heartRate) else {
                completion(nil)
                return
            }

            /// Predicate for specifiying start and end dates for the query
            let predicate = HKQuery
                .predicateForSamples(
                    withStart: Date.distantPast,
                    end: Date(),
                    options: .strictEndDate)

            /// Set sorting by date.
            let sortDescriptor = NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false)

            /// Create the query
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: Int(HKObjectQueryNoLimit),
                sortDescriptors: [sortDescriptor]) { (_, results, error) in

                    guard error == nil else {
                        print("Error: \(error!.localizedDescription)")
                        return
                    }

                    guard let results = results, results.count > 0 else {
                        return
                    }
                    //print(results)

                    completion(results[0] as? HKQuantitySample)
                }

            self.healthStore.execute(query)
        }

    /// Requests authorisation from the user to be able to save data
    /// to heathkit.
    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not avaliable on the device")
            return
        }

        self
            .healthStore
            .requestAuthorization(
                toShare: [
                    HKWorkoutType.workoutType(),
                    HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                    HKObjectType.quantityType(forIdentifier: .heartRate)!
                ],
                read: [
                    HKObjectType.quantityType(forIdentifier: .heartRate)!
                ],
                completion: { success, error in
                    print("success", success)
                    print("error:", error ?? "no error")
                })
    }

    
}
