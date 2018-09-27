//
//  delete.swift
//  InsViewer
//
//  Created by Renrui Liu on 27/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation
import Firebase
import SCLAlertView


func deleteFromFirebase(post: Post){
    //deletion
    guard let uid = Auth.auth().currentUser?.uid else {return}
    guard let postId = post.id else {return}
    Database.database().reference().child("posts").child(uid).child(postId).removeValue(completionBlock: { (err, ref) in
        if let _ = err {
            showErr(info: "Failed to remove this post", subInfo: tryLater)
            return
        }
        
        showSuccess(info: "Successfully deleted post", subInfo: "")
        
        // notify refresh
        NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
    })
}

func unfollow(currentUserId: String, targetUid: String){
    //Unfollow
    Database.database().reference().child("following").child(currentUserId).child(targetUid).removeValue { (err, ref) in
        if let _ = err {
            showErr(info: "Failed to unfollow user", subInfo: tryLater)
            return
        }
        showSuccess(info: "Successfully unfollowed user", subInfo: "")
        
        NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
    }
}

func hidePost(post: Post) {
    guard let uid = Auth.auth().currentUser?.uid else {return}
    guard let postID = post.id else {return}
    let values = ["userId": post.user.uid]
    Database.database().reference().child("hide").child(uid).child(postID).updateChildValues(values) { (err, _) in
        if let _ = err {
            showErr(info: "Failed to hide the post", subInfo: tryLater)
            return
        }
        showSuccess(info: "Successfully hided the post", subInfo: "")
        
        NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
    }
}

func reportPost(post: Post, reason: String) {
    guard let uid = Auth.auth().currentUser?.uid else {return}
    guard let postID = post.id else {return}
    let values = ["reporterID": uid, "reportReason":reason]
    Database.database().reference().child("report").child(postID).updateChildValues(values) { (err, _) in
        if let _ = err {
            showErr(info: "Failed to report the post", subInfo: tryLater)
            return
        }
        showSuccess(info: "Successfully reported the post", subInfo: "")
    }
}

