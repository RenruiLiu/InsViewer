//
//  MainTabBarViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 11/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarViewController: UITabBarController {
    
    func setupViewControllers(){
    // setup navigation controller
    let layout = UICollectionViewFlowLayout()
    let userProfileController = UserProfileViewController(collectionViewLayout: layout)
    let navController = UINavigationController(rootViewController: userProfileController)
    
    // setup tab bar
    navController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
    navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
    tabBar.tintColor = .black
    
    viewControllers = [navController]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //check login status if not login yet:
        if Auth.auth().currentUser == nil{
            // wait until the main tab bar controller is inside of the UI, then lead us to login
            DispatchQueue.main.async {
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        //login already
        setupViewControllers()

    }
    
}
