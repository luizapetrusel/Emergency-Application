//
//  ForgotUsernameController.swift
//  EmergencyApplication
//
//  Created by Luiza Petrusel on 23.11.2022.
//

import UIKit
import RealmSwift

class ForgotUsernameController: UIViewController {
    
    @IBOutlet weak var changeUsernameButton: UIButton!
    @IBOutlet weak var mailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextfield.isSecureTextEntry = true
        configureButtonsCorner()
    }
    
    func configureButtonsCorner() {
        changeUsernameButton.layer.cornerRadius = 0.04 * changeUsernameButton.bounds.size.width
    }
    
    @IBAction func changeUsernameButtonTapped(_sender: UIButton) {
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        let nrOfUsers = realm.objects(Users.self).count
        
        let users = realm.objects(Users.self)

        var i = 0
        let mailInput = mailTextfield?.text
        let passwordInput = passwordTextfield?.text

        var mail: String
        var password: String

        repeat {
            mail = users[i].mail!
            password = users[i].password!

            if mailInput!.isEmpty && passwordInput!.isEmpty {
                print("Please enter a valid email address and password.")
                showAlert("You need to fill in a email address and a password.")
                shakeField(_field: mailTextfield)
                shakeField(_field: passwordTextfield)
            } else if mailInput!.isEmpty {
                print("Please enter a valid email address.")
                showAlert("You need to fill in a email address.")
                shakeField(_field: mailTextfield)
            } else if passwordInput!.isEmpty{
                print("Please enter a valid password.")
                showAlert("You need to fill in a password.")
                shakeField(_field: passwordTextfield)
            } else if (mail == mailInput && password == passwordInput) {
                print("Email address and password are correct.")
                mailTextfield.text = ""
                passwordTextfield.text = ""
                presentControllerHalf()
                NotificationCenter.default.post(name: Notification.Name("mail"), object: mailInput)
                NotificationCenter.default.post(name: Notification.Name("password"), object: passwordInput)
                userInteractionBehindController(false, forgotUsernameController: self)
                break
            }
            i+=1
        } while i < nrOfUsers
        if i == nrOfUsers{
            mail = users[i-1].mail!
            password = users[i-1].password!
            if (mail != mailInput || password != passwordInput) {
                print("Incorrect email address or password.")
                showAlert("Please input the correct credentials", "Wrong credentials")
                shakeField(_field: mailTextfield)
                shakeField(_field: passwordTextfield)
            }
        }
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func shakeField(_field: UITextField) {
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.values = [0, 10, -10, 10, 0]
        animation.keyTimes = [0, 0.08, 0.25, 0.415, 0.5]
        animation.duration = 0.5
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        _field.layer.add(animation,forKey: nil)
    }
    
    private func presentControllerHalf() {
        let changeUsernameController = ChangeUsernameController()
        changeUsernameController.view.translatesAutoresizingMaskIntoConstraints = false
        attachChildController(changeUsernameController)
        NSLayoutConstraint.activate([
            changeUsernameController.view.bottomAnchor.constraint(equalTo: view.superview!.bottomAnchor),
            changeUsernameController.view.trailingAnchor.constraint(equalTo: view.superview!.trailingAnchor),
            changeUsernameController.view.leadingAnchor.constraint(equalTo: view.superview!.leadingAnchor),
            changeUsernameController.view.heightAnchor.constraint(equalToConstant: self.view.frame.height/3)
        ])

    }
    
    func attachChildController(_ child: UIViewController) {
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func userInteractionBehindController(_ condition: Bool, forgotUsernameController: ForgotUsernameController) {
        forgotUsernameController.mailTextfield?.isUserInteractionEnabled = condition
        forgotUsernameController.passwordTextfield?.isUserInteractionEnabled = condition
        forgotUsernameController.changeUsernameButton?.isUserInteractionEnabled = condition
    }

    func showAlert(_ message: String, _ title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

}
