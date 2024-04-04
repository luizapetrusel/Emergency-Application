//
//  ForgotPasswordController.swift
//  EmergencyApplication
//
//  Created by Luiza Petrusel on 23.11.2022.
//

import UIKit
import RealmSwift

class ForgotPasswordController: UIViewController {
    
    @IBOutlet weak var mailTextfield: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtonsCorner()
    }
    
    func configureButtonsCorner() {
        changePasswordButton.layer.cornerRadius = 0.04 * changePasswordButton.bounds.size.width
    }
    
    @IBAction func changePasswordButtonTapped(_sender: UIButton) {
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        let nrOfUsers = realm.objects(Users.self).count
        
        let users = realm.objects(Users.self)

        var i = 0
        let mailInput = mailTextfield?.text
        let usernameInput = usernameTextfield?.text

        var mail: String
        var username: String

        repeat {
            mail = users[i].mail!
            username = users[i].username!

            if usernameInput!.isEmpty && mailInput!.isEmpty {
                print("Please enter a valid email address and username.")
                showAlert("You need to fill in a email address and a username.")
                shakeField(_field: mailTextfield)
                shakeField(_field: usernameTextfield)
            } else if mailInput!.isEmpty {
                print("Please enter a valid email address.")
                showAlert("You need to fill in a email address.")
                shakeField(_field: mailTextfield)
            } else if usernameInput!.isEmpty{
                print("Please enter a valid username.")
                showAlert("You need to fill in a username.")
                shakeField(_field: usernameTextfield)
            } else if (mail == mailInput && username == usernameInput) {
                print("Email address and username are correct.")
                usernameTextfield.text = ""
                mailTextfield.text = ""
                presentControllerHalf()
                NotificationCenter.default.post(name: Notification.Name("mail"), object: mailInput)
                NotificationCenter.default.post(name: Notification.Name("username"), object: usernameInput)
                userInteractionBehindController(false, forgotPasswordController: self)
                break
            }
            i+=1
        } while i < nrOfUsers
        if i == nrOfUsers{
            mail = users[i-1].mail!
            username = users[i-1].username!
            if (mail != mailInput || username != usernameInput) {
                print("Incorrect email address or username.")
                showAlert("Please input the correct credentials", "Wrong credentials")
                shakeField(_field: mailTextfield)
                shakeField(_field: usernameTextfield)
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
        let changePasswordController = ChangePasswordController()
        changePasswordController.view.translatesAutoresizingMaskIntoConstraints = false
        attachChildController(changePasswordController)
        NSLayoutConstraint.activate([
            changePasswordController.view.bottomAnchor.constraint(equalTo: view.superview!.bottomAnchor),
            changePasswordController.view.trailingAnchor.constraint(equalTo: view.superview!.trailingAnchor),
            changePasswordController.view.leadingAnchor.constraint(equalTo: view.superview!.leadingAnchor),
            changePasswordController.view.heightAnchor.constraint(equalToConstant: self.view.frame.height/3)
        ])

    }
    
    func attachChildController(_ child: UIViewController) {
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func userInteractionBehindController(_ condition: Bool, forgotPasswordController: ForgotPasswordController) {
        forgotPasswordController.mailTextfield?.isUserInteractionEnabled = condition
        forgotPasswordController.usernameTextfield?.isUserInteractionEnabled = condition
        forgotPasswordController.changePasswordButton?.isUserInteractionEnabled = condition
    }

    func showAlert(_ message: String, _ title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
