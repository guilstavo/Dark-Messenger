//
//  ViewController.swift
//  Fire Messenger
//
//  Created by Gustavo M Santos on 01/10/2018.
//  Copyright © 2018 Gustavo M Santos. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet var viewBackground: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = 25
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        viewBackground.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped() {
        emailTextField.endEditing(true)
        nameTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" && nameTextField.text != "" {
            emailTextField.isEnabled = false
            passwordTextField.isEnabled = false
            nameTextField.isEnabled = false
            SVProgressHUD.show()
            
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                if error != nil {
                    self.showError(error: error!)
                } else {
                    let userDB = Database.database().reference().child("User")
                    let UserDictionary = [
                        "uid": String(Auth.auth().currentUser!.uid),
                        "email": self.emailTextField.text!,
                        "name": self.nameTextField.text!
                    ]
                    
                    userDB.child(UserDictionary["uid"]!).setValue(UserDictionary) {
                        (error, reference) in
                        if error != nil {
                            self.showError(error: error!)
                        } else {
                            let userRefDB = Database.database().reference().child("User-Ref")
                            let emailRef = self.emailTextField.text!.replacingOccurrences(of: ".", with: ",", options: .literal, range: nil)
                            
                            userRefDB.child(emailRef).setValue(String(Auth.auth().currentUser!.uid)) {
                                (error, reference) in
                                if error != nil {
                                    self.showError(error: error!)
                                } else {
                                    print("User saved successfully!")
                                }
                            }
                        }
                    }
                    self.emailTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                    self.nameTextField.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "goToUserList", sender: self)
                }
            }
        }
    }
    
    func showError(error: Error) {
        SVProgressHUD.dismiss()
        handleError(error)
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
        nameTextField.isEnabled = true
    }
}

