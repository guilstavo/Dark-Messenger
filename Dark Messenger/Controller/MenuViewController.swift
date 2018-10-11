//
//  MenuViewController.swift
//  Dark Messenger
//
//  Created by Gustavo M Santos on 11/10/2018.
//  Copyright © 2018 Gustavo M Santos. All rights reserved.
//

import UIKit
import Firebase
import SideMenu

class MenuViewController: UIViewController {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        SideMenuManager.default.menuWidth = max(round(min((screenSize.width), (screenSize.height)) * 0.85), 240)
        
    }

    
    @IBAction func logOutPressed(_ sender: Any) {
        
        let logOutAlert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: .actionSheet)
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController {
                    
                    let navVC = mainStoryboard.instantiateViewController(withIdentifier: "navigationController") as! UINavigationController
                    
                    // set the "root" VC of the NavVC to your SearchResultsTableViewController
                    navVC.setViewControllers([viewController], animated: false)
                    
                    // use the new NavVC as the new rootViewController
                    UIApplication.shared.keyWindow?.rootViewController = navVC
                    UIApplication.shared.keyWindow?.rootViewController?.navigationController?.popToRootViewController(animated: true)
                }
            } catch {
                print("error, thare was a problem signing out")
            }
        }
        
        logOutAlert.addAction(logOutAction)
        logOutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(logOutAlert, animated: true, completion: nil)
    }
}
