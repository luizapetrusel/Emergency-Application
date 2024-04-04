//
//  ChangeUsernameController.swift
//  EmergencyApplication
//
//  Created by Luiza Petrusel on 23.11.2022.
//

import UIKit
import RealmSwift

class ChangeUsernameController: UIViewController {
    
    @IBOutlet weak var newUsernameTextfield: UITextField!
    @IBOutlet weak var resetUsernameButton: UIButton!
    
    var mailInput: String = ""
    var passwordInput: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtonsCorner()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotificationMail(_:)), name: Notification.Name("mail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotificationPassword(_:)), name: Notification.Name("password"), object: nil)
    }
    
    @objc func didGetNotificationMail(_ notification: Notification) {
        let mail = notification.object as! String?
        mailInput = mail!
    }
    
    @objc func didGetNotificationPassword(_ notification: Notification) {
        let password = notification.object as! String?
        passwordInput = password!
    }
    
    @IBAction func exitButtonTapped(_sender: UIButton) {
        let forgotUsernameController = ForgotUsernameController()
        if self.parent != nil {
            forgotUsernameController.userInteractionBehindController(true, forgotUsernameController: self.parent as! ForgotUsernameController)
        }
        self.detachFromParentController()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetUsernameButtonTapped(_sender: UIButton) {
        let usernameInput = newUsernameTextfield.text!
        
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)

        let userResulted = realm.objects(Users.self).filter("password = '"+passwordInput+"'").filter("mail = '"+mailInput+"'").first!
        
        try! realm.write {
            userResulted.username = usernameInput
        }
        showAlert("Your username has been changed", "Congratulations!")
        newUsernameTextfield.text = ""
    }
    
    func configureButtonsCorner() {
         resetUsernameButton.layer.cornerRadius = 0.04 * resetUsernameButton.bounds.size.width
    }
    
    func detachFromParentController() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    func showAlert(_ message: String, _ title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
