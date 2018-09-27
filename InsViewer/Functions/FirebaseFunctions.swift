//
//  delete.swift
//  InsViewer
//
//  Created by Renrui Liu on 27/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation
import Firebase

func deleteFromFirebase(post: Post){
    //deletion
    guard let uid = Auth.auth().currentUser?.uid else {return}
    guard let postId = post.id else {return}
    Database.database().reference().child("posts").child(uid).child(postId).removeValue(completionBlock: { (err, ref) in
        if let err = err {
            
            let alert = showAlert(title: "Failed to remove the post", text: "please try again later")
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            print("Failed to remove this post",err)
        }
        // notify refresh
        
        NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
    })
}

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

func hidePost(post: Post) {
    guard let uid = Auth.auth().currentUser?.uid else {return}
    guard let postID = post.id else {return}
    let values = ["userId": post.user.uid]
    Database.database().reference().child("hide").child(uid).child(postID).updateChildValues(values) { (err, _) in
        if let err = err {
            print("Failed to hide the post:",err)
            return
        }
        print("Successfully hided the post")
        NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
    }
}

func reportPost(post: Post, reason: String) {
    guard let uid = Auth.auth().currentUser?.uid else {return}
    guard let postID = post.id else {return}
    let values = ["reporterID": uid, "reportReason":reason]
    Database.database().reference().child("report").child(postID).updateChildValues(values) { (err, _) in
        if let err = err {
            print("Failed to report the post:",err)
            return
        }
        print("Successfully reported the post")
    }
}

