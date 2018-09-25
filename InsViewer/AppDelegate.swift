//
//  AppDelegate.swift
//  InsViewer
//
//  Created by Renrui Liu on 9/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        window = UIWindow()
        window?.rootViewController = MainTabBarViewController()
        
        attemptRegisterForNotifications(application: application)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    //_______________Notification________________
    private func attemptRegisterForNotifications(application: UIApplication){
        // APNS: Apple push notification Services
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // send notification with alert badge and sound
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        // ask user for authorization via a popup alert
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
            if let err = err {
                print("Failed to request auth:",err)
                return
            }
            if granted{
                print("Auth granted")
            } else {
                print("Auth denied")
            }
        }
        
        application.registerForRemoteNotifications()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for notifications:", deviceToken)
    }
    
    //FCM: Firebase Cloud Messaging
    // get current device fcm token
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Registered with FCM with token:", fcmToken)
    }
    
    // listen for user notifications // show notification alert when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    // tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // get the followerID from userInfo dictionary
        if let followerId = userInfo["followerID"] as? String {
            // push to the userprofile for the follower
            let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileVC.userId = followerId
            
            // access main UI from AppDelegate
            if let mainTabBarController = window?.rootViewController as? MainTabBarViewController {
                
                // jump to home
                mainTabBarController.selectedIndex = 0
                mainTabBarController.presentedViewController?.dismiss(animated: true, completion: nil)
                
                if let homeNavigationController = mainTabBarController.viewControllers?.first as? UINavigationController {
                    homeNavigationController.pushViewController(userProfileVC, animated: true)
                }
            }
        }
    }
    
}

