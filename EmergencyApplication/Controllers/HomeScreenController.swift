//
//  HomeScreenController.swift
//  EmergencyApplication
//
//  Created by Luiza Petrusel on 23.10.2022.
//

import UIKit
import HealthKit
import SpriteKit

class HomeScreenController: UIViewController {
    
    @IBOutlet weak var registerButton: UIBarButtonItem!
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var loginAsAdmin: UIBarButtonItem!
    @IBOutlet weak var pin: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let newNavBarAppearance = UINavigationBarAppearance()
        newNavBarAppearance.configureWithTransparentBackground()
        newNavBarAppearance.backgroundColor = UIColor(named: "AppColor")
        navBar.standardAppearance = newNavBarAppearance
        
        let healthStore = HKHealthStore()
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not avaliable on the device")
            return
        }

        healthStore
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
                    print("error", error ?? "no error")
                })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preparePinAnimation(element: pin)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enlargePinAnimation(true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated
    }
    
    @IBAction func presentRegister(_ sender: UIBarButtonItem) {
        let registerController = RegisterController()
        present(registerController, animated: true)
    }
    
    @IBAction func loginAdmin(_ sender: UIBarButtonItem) {
        let loginAdminController = LoginAdminController()
        present(loginAdminController, animated: true)
    }

    private func preparePinAnimation(element: UIView) {
        element.transform = CGAffineTransform(scaleX: 0, y: 0)
    }

    private func enlargePinAnimation(_ animated: Bool) {
        UIView.animate(withDuration: 3.0,
                       animations: {
            self.pin.frame.origin.y = 216
            self.pin.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }


}
