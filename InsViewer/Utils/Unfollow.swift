//
//  Unfollow.swift
//  InsViewer
//
//  Created by Renrui Liu on 19/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation
import Firebase

func unfollow(currentUserId: String, targetUid: String){
    //Unfollow
    Database.database().reference().child("following").child(currentUserId).child(targetUid).removeValue { (err, ref) in
        if let err = err {
            print("Failed to unfollow user:", err)
            return
        }
        print("Successfully unfollowed user")
        
        NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
    }
}
