//
//  Extensions.swift
//  InsViewer
//
//  Created by Renrui Liu on 10/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

extension UIColor{
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
}

extension UIView{
    func anchor(top: NSLayoutYAxisAnchor?, paddingTop: CGFloat, bottom: NSLayoutYAxisAnchor?, paddingBottom: CGFloat, left: NSLayoutXAxisAnchor?, paddingLeft: CGFloat, right: NSLayoutXAxisAnchor?, paddingRight: CGFloat, width: CGFloat, height: CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top{
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true}
        if let bottom = bottom{
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true}
        if let left = left{
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true}
        if let right = right{
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true}
        if width != 0 {widthAnchor.constraint(equalToConstant: width).isActive = true}
        if height != 0 {heightAnchor.constraint(equalToConstant: height).isActive = true}
    }
}

extension Database {
    static func fetchUserWithUID(uid: String, completion: @escaping (UserProfile)->()){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // fetch user
            //setup dictionary
            guard let userDictionary = snapshot.value as? [String:Any] else {return}
            let user = UserProfile(uid: uid, dict: userDictionary)
            completion(user)
        }) { (err) in
            print("Failed to fetch user for posts: ", err)
        }
    }
}

extension Date{
    func timeAgoDisplay() -> String{
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let min = 60
        let hour = 60 * min
        let day = 24 * hour
        let week = 7 * day
        let year = 365 * day
        
        let second = NSLocalizedString("second", comment: "")
        let minute = NSLocalizedString("minute", comment: "")
        let hours = NSLocalizedString("hour", comment: "")
        let days = NSLocalizedString("day", comment: "")
        let weeks = NSLocalizedString("week", comment: "")
        let years = NSLocalizedString("year", comment: "")
        let ago = NSLocalizedString("ago", comment: "")
        
        if secondsAgo < 10{
            return "Just now"
        } else if secondsAgo < min {
            return "\(secondsAgo) \(second) \(ago)"
        } else if secondsAgo < hour {
            return "\(secondsAgo / min) \(minute) \(ago)"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) \(hours) \(ago)"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) \(days) \(ago)"
        } else if secondsAgo < year {
            return "\(secondsAgo / week) \(weeks) \(ago)"
        }
        return "\(secondsAgo / year) \(years) \(ago)"
    }
}

extension UIResponder {
    func parentController<T: UIViewController>(of type: T.Type) -> T? {
        guard let next  = self.next else {return nil}
        return (next as? T) ?? next.parentController(of: T.self)
    }
}


