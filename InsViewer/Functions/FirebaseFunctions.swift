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

func follow(userA: String, userB: String, completion: @escaping (Bool)->Void){
    // access firebase tree: following -> currentuser -> [[user1 : 1],...]
    let followingRef = Database.database().reference().child("following").child(userA)
    let followingValue = [userB: 1]
    followingRef.updateChildValues(followingValue) { (err, ref) in
        if let err = err {
            print("Failed to follow user: ", err)
            return
        }
        // save follower into db
        let followerRef = Database.database().reference().child("followers").child(userB)
        let followerValue = [userA: 1]
        followerRef.updateChildValues(followerValue) { (err, ref) in
            if let err = err {
                print("Failed to save follower to db:",err)
                completion(false)
                return
            }
            completion(true)
        }
    }
}

// userA blocks userB
func block(userA: String, userB: String){
    // block user // unblock in rightbar item
    let alertView = SCLAlertView()
    alertView.addButton("Yes", action: {
        // block = unfollow + no comment + unable to follow
        // unblock = follow + cancel block
        let values = [userA: "1"]
        Database.database().reference().child("block").child(userB).updateChildValues(values, withCompletionBlock: { (err, _) in
            if let _ = err {
                showErr(info: "Failed to block the user", subInfo: tryLater)
                return
            }
            unfollow(currentUserId: userB, targetUid: userA)
            unfollow(currentUserId: userA, targetUid: userB)
            showSuccess(info: "Successfully blocked the user", subInfo: "")
        })
    })
    alertView.showWarning("Are you sure to block the user?", subTitle: "You will unfollow this user and he/she won't be able to follow or comment you", closeButtonTitle: "Cancel")
}

// userA blocks userB
func unblock(userA: String, userB: String){
    Database.database().reference().child("block").child(userB).child(userA).removeValue { (err, _) in
        if let _ = err {
            showErr(info: "Failed to unblock the user", subInfo: tryLater)
            return
        }
    }
}
