//
//  MainTabBarViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 11/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
}
