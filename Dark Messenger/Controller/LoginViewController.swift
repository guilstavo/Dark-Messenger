//
//  LoginViewCOntroller.swift
//  Fire Messenger
//
//  Created by Gustavo M Santos on 01/10/2018.
//  Copyright © 2018 Gustavo M Santos. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet var viewBackground: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 25
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        viewBackground.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped() {
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            emailTextField.isEnabled = false
            passwordTextField.isEnabled = false
            SVProgressHUD.show()
            
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                if error != nil {
                    self.showError(error: error!)
                } else {
                    print("Login was successful")
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
    }
    
}
