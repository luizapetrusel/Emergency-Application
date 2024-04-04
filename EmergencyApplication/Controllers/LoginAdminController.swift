//
//  LoginAdminController.swift
//  EmergencyApplication
//
//  Created by Luiza Petrusel on 02.12.2022.
//

import UIKit
import RealmSwift

class LoginAdminController: UIViewController {
    
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtonsCorner()
        passwordTextfield.isSecureTextEntry = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        slideFromLeft(constraint: usernameConstraint)
        slideFromRight(constraint: passwordConstraint)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textfieldsAnimation(true)
    }
    
    @IBAction func exitButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginTapped( _sender: UIButton) {
        let realm = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        let nrOfUsers = realm.objects(Admins.self).count
        
        let admins = realm.objects(Admins.self)
        
        var i = 0
        let userInput = usernameTextfield?.text
        let passwordInput = passwordTextfield?.text

        var username: String
        var mail: String
        var password: String

        repeat {
            username = admins[i].username!
            mail = admins[i].mail!
            password = admins[i].password!

            if userInput!.isEmpty && passwordInput!.isEmpty {
                print("Please enter a valid username and password.")
                showAlert("You need to fill in a username and a password.")
                shakeField(_field: usernameTextfield)
                shakeField(_field: passwordTextfield)
            } else if userInput!.isEmpty {
                print("Please enter a valid username.")
                showAlert("You need to fill in a username.")
                shakeField(_field: usernameTextfield)
            } else if passwordInput!.isEmpty{
                print("Please enter a valid password.")
                showAlert("You need to fill in a password.")
                shakeField(_field: passwordTextfield)
            } else if (username == userInput && password == passwordInput) ||
            (mail == userInput && password == passwordInput){
                print("Username and password are correct.")
                usernameTextfield.resignFirstResponder()
                passwordTextfield.resignFirstResponder()
                let adminController = AdminController()
                attachChildController(adminController)
                break
            }
            i+=1
        } while i < nrOfUsers
        if i == nrOfUsers{
            username = admins[i-1].username!
            password = admins[i-1].password!
            if (username != userInput || password != passwordInput) ||
            (mail != userInput || password != passwordInput){
                print("Incorrect username or password.")
                shakeField(_field: usernameTextfield)
                shakeField(_field: passwordTextfield)
            }
        }
    }
    
    func attachChildController(_ child: UIViewController) {
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    private func textfieldsAnimation(_ animated: Bool) {
        UIView.animate(withDuration: 2.0,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
            self.usernameConstraint.constant += self.view.bounds.width
            self.passwordConstraint.constant -= self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func slideFromLeft(constraint: NSLayoutConstraint) {
        constraint.constant -= view.bounds.width
    }
    
    private func slideFromRight(constraint: NSLayoutConstraint) {
        constraint.constant += view.bounds.width
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
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func configureButtonsCorner() {
        loginButton.layer.cornerRadius = 0.03 * loginButton.bounds.size.width
    }

}
