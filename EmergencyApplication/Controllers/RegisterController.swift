//
//  RegisterController.swift
//  EmergencyApplication
//
//  Created by Luiza Petrusel on 25.10.2022.
//

import UIKit
import RealmSwift

class RegisterController: UIViewController {
    
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var accountImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextfield.isSecureTextEntry = true
        confirmPasswordTextfield.isSecureTextEntry = true
        configureButtonsCorner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fadeAnimation(element: accountImage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        accountIconAnimation(true)
        
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        
        let usernameInput = usernameTextfield.text!
        let mailInput = mailTextField.text!
        let passwordInput = passwordTextfield.text!
        let confirmPasswordInput = confirmPasswordTextfield.text!
        
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)

        if mailInput.contains("@") && mailInput.contains(".") {

            if passwordInput == confirmPasswordInput {
                let user = Users()
                user.username = usernameInput
                user.mail = mailInput
                user.password = passwordInput

                try! realm.write {
                    realm.add(user)
                }
                showAlert("Your account has been created", "Welcome!")
                usernameTextfield.text = ""
                passwordTextfield.text = ""
                mailTextField.text = ""
                confirmPasswordTextfield.text = ""
            } else {
                showAlert("Passwords do NOT match!", "Error")
                passwordTextfield.text = ""
                confirmPasswordTextfield.text = ""
            }


        } else {
            showAlert("Your mail is not valid", "Error")
        }

    }
    
    @IBAction func exitButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func showAlert(_ message: String, _ title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func configureButtonsCorner() {
        registerButton.layer.cornerRadius = 0.03 * registerButton.bounds.size.width
    }
    
    private func fadeAnimation(element: UIView) {
        element.alpha = 0
    }
    
    private func accountIconAnimation(_ animated: Bool) {
        UIView.animate(withDuration: 3.0,
                       animations: {
            self.accountImage.alpha = 1.0
        })
    }
    
}
