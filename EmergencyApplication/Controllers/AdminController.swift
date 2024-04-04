//
//  AdminController.swift
//  EmergencyApplication
//
//  Created by Luiza Petrusel on 25.10.2022.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

class AdminController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var label:UILabel!
    @IBOutlet weak var usersLabel: UILabel!
    
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayUsers()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func displayUsers(){
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        let nrOfUsers = realm.objects(UsersInDanger.self).count
        
        let usersInDanger = realm.objects(UsersInDanger.self)
        
        var i = 0

        if nrOfUsers > 0 {
            repeat {
                let latitude = Double(usersInDanger[i].latitude!)
                let longitude = Double(usersInDanger[i].longitude!)

                let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)

                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)//0.05

                let region = MKCoordinateRegion(center: coordinate, span: span)

                mapView.setRegion(region, animated: true)

                let pin = MKPointAnnotation()

                pin.coordinate = coordinate
                mapView.addAnnotation(pin)
                i+=1
            } while i < nrOfUsers
        } else {
            label.isHidden = false
            mapView.isHidden = true
            usersLabel.isHidden = true
        }
    }

    @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let realm = try! Realm()

        if gestureRecognizer.state == .ended {
            let tappedPoint = gestureRecognizer.location(in: mapView)
            let tappedCoordinates = mapView.convert(tappedPoint, toCoordinateFrom: mapView)

            for annotation in mapView.annotations {
                if let pin = annotation as? MKPointAnnotation {
                    let pinCoordinates = pin.coordinate
                    if abs(pinCoordinates.latitude - tappedCoordinates.latitude) < 0.0001 &&
                        abs(pinCoordinates.longitude - tappedCoordinates.longitude) < 0.0001 {

                        let alert = UIAlertController(title: "", message: "Delete this pin?", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                            NSLog("The \"No\" alert occured.")
                        }))
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                            NSLog("The \"Yes\" alert occured.")
                            self.mapView.removeAnnotation(pin)
                            //let pinLongituteString = String(format: "%.6f", pinCoordinates.longitude)
                            //let pinLatitudeString = String(format: "%.6f", pinCoordinates.latitude)
                            let pinLongituteString = String(pinCoordinates.longitude)
                            let pinLatitudeString = String(pinCoordinates.latitude)

                            let pinToDelete = realm.objects(UsersInDanger.self).filter("longitude = '"+pinLongituteString+"'").filter("latitude = '"+pinLatitudeString+"'").first!
                            try! realm.write {
                                realm.delete(pinToDelete)
                            }

                        }))
                        self.present(alert, animated: true, completion: nil)
                    }

                }
            }
        }
    }
}






