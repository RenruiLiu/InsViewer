//
//  MainTabBarViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 11/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate, UIImagePickerControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        if index == 2 {
            // go to photo selection page
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorCollectionViewController(collectionViewLayout: layout)
            let navController = UINavigationController(rootViewController: photoSelectorController)
            present(navController, animated: true, completion: nil)

            return false
        }
        return true
    }
    
    func setupViewControllers(){
        // home
        let homeNavController = templateNavController(unselectedImg: #imageLiteral(resourceName: "home_unselected"), selectedImg: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        // search
        let searchNavController = templateNavController(unselectedImg: #imageLiteral(resourceName: "search_unselected"), selectedImg: #imageLiteral(resourceName: "search_selected"), rootViewController: UserSearchViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        // plus
        let plusNavController = templateNavController(unselectedImg: #imageLiteral(resourceName: "plus_unselected"), selectedImg: #imageLiteral(resourceName: "plus_unselected"))
        // like
        let likeNavContoller = templateNavController(unselectedImg: #imageLiteral(resourceName: "like_unselected"), selectedImg: #imageLiteral(resourceName: "like_selected"))
        
        // user profile page using navigation controller
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileViewController(collectionViewLayout: layout)
        let userProfileNavContoller = UINavigationController(rootViewController: userProfileController)
        // setup tab bar icons
        userProfileNavContoller.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        userProfileNavContoller.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        tabBar.tintColor = .black
        
        viewControllers = [homeNavController,
                           searchNavController,
                           plusNavController,
                           likeNavContoller,
                           userProfileNavContoller]
        
        // adjust the position of icon in tab bar
        guard let items = tabBar.items else {return}
        for item in items{
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    //____________________________________________________________________________________
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

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
    
    //____________________________________________________________________________________
    fileprivate func templateNavController(unselectedImg: UIImage, selectedImg: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController{
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImg
        navController.tabBarItem.selectedImage = selectedImg
        return navController
    }
}
