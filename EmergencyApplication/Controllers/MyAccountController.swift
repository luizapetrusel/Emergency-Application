//
//  MyAccountController.swift
//  EmergencyApplication
//
//  Created by Luiza Petrusel on 23.10.2022.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

class MyAccountController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dangerButton: UIButton!
    @IBOutlet weak var dangerLabel: UILabel!
    
    let manager = CLLocationManager()
    
    var usernameAccount: String = ""
    var mailAccount: String = ""
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0);                                         
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.endEditing(true)
        dangerLabel.alpha = 0
        configureButtonsCorner()
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotificationMailAccount(_:)), name: Notification.Name("mailAccount"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotificationUsernameAccount(_:)), name: Notification.Name("usernameAccount"), object: nil)
    }
    
    @objc func didGetNotificationMailAccount(_ notification: Notification) {
        let mail = notification.object as! String?
        mailAccount = mail!
    }
    
    @objc func didGetNotificationUsernameAccount(_ notification: Notification) {
        let username = notification.object as! String?
        usernameAccount = username!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //defines how often we want the accuracy of the location
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        manager.delegate = self
        
        //request permission from user
        manager.requestWhenInUseAuthorization()

        locationManagerDidChangeAuthorization(manager)
        
        manager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
         case .authorizedWhenInUse:
            //permissions granted
            break
        case .denied, .restricted:
            showLocationPermissionDeniedAlert()
            break
        default:
            break
        }
    }

    //delegate function
    //is called when we start the manager's location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //locations is the array of the locations from the manager
        if let location = locations.first {
            manager.stopUpdatingLocation()
            render(location)
        }
    }
    
    //zooming the map in our area
    func render(_ location: CLLocation) {
        
        coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude)
        longitudeLabel.text = coordinate.longitude.description
        latitudeLabel.text = coordinate.latitude.description
        
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        let location = Locations()
        
        usernameLabel.text = usernameAccount
        location.username = usernameAccount
        location.mail = mailAccount
        location.longitude = coordinate.longitude.description
        location.latitude = coordinate.latitude.description
        
        try! realm.write {
            realm.add(location)
        }

        //how much of a span you want to show
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
        let pin = MKPointAnnotation()
        
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
    }
    
    @IBAction func dangerButtonPressed() {
        showAlert()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
            NSLog("The \"No\" alert occured.")
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            NSLog("The \"Yes\" alert occured.")
            self.addUserInDanger()
            self.dangerLabel.alpha = 1
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addUserInDanger() {
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        let userInDanger = UsersInDanger()
        
        userInDanger.username = usernameAccount
        userInDanger.mail = mailAccount
        userInDanger.longitude = coordinate.longitude.description
        userInDanger.latitude = coordinate.latitude.description
        
        try! realm.write {
            realm.add(userInDanger)
        }
    }
    
    func configureButtonsCorner() {
         dangerButton.layer.cornerRadius = 0.04 * dangerButton.bounds.size.width
    }

    func showLocationPermissionDeniedAlert() {
        let alertController = UIAlertController(title: "Location Permission Denied", message: "Please enable location services in Settings to use this feature.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {return}
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

}
