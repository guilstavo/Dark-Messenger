//
//  WelcomeViewController.swift
//  Fire Messenger
//
//  Created by Gustavo M Santos on 02/10/2018.
//  Copyright © 2018 Gustavo M Santos. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = 25
        loginButton.layer.cornerRadius = 25
        
//        Auth.auth().addStateDidChangeListener { (auth, user) in
//            if (user != nil) {
//                self.performSegue(withIdentifier: "goToUserList", sender: self)
//            }
//        }
    }
}
