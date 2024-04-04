//
//  ChangePasswordController.swift
//  EmergencyApplication
//
//  Created by Luiza Petrusel on 24.11.2022.
//

import UIKit
import RealmSwift

class ChangePasswordController: UIViewController {

    @IBOutlet weak var newPasswordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    var usernameInput: String = ""
    var mailInput: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtonsCorner()
        newPasswordTextfield.isSecureTextEntry = true
        confirmPasswordTextfield.isSecureTextEntry = true
        
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotificationMail(_:)), name: Notification.Name("mail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotificationUsername(_:)), name: Notification.Name("username"), object: nil)
    }
    
    @objc func didGetNotificationMail(_ notification: Notification) {
        let mail = notification.object as! String?
        mailInput = mail!
    }
    
    @objc func didGetNotificationUsername(_ notification: Notification) {
        let username = notification.object as! String?
        usernameInput = username!
    }
    
    @IBAction func exitButtonTapped(_sender: UIButton) {
        let forgotPasswordController = ForgotPasswordController()
        if self.parent != nil {
            forgotPasswordController.userInteractionBehindController(true, forgotPasswordController: self.parent as! ForgotPasswordController)
        }
        self.detachFromParentController()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetUsernameButtonTapped(_sender: UIButton) {
        let passwordInput = newPasswordTextfield.text!
        let confirmPasswordInput = confirmPasswordTextfield.text!
        
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)

        if passwordInput == confirmPasswordInput {
            let userResulted = realm.objects(Users.self).filter("username = '"+usernameInput+"'").filter("mail = '"+mailInput+"'").first!
            
            try! realm.write {
                userResulted.password = passwordInput
            }
            newPasswordTextfield.text = ""
            confirmPasswordTextfield.text = ""
            showAlert("Your password has been changed", "Congratulations!")
        } else {
            showAlert("Passwords do NOT match!","Error")
            newPasswordTextfield.text = ""
            confirmPasswordTextfield.text = ""
        }
    }
    
    func configureButtonsCorner() {
         resetPasswordButton.layer.cornerRadius = 0.04 * resetPasswordButton.bounds.size.width
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
