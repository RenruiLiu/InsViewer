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
    
    let ref = Database.database().reference().child("posts").child(uid).child(postId)
    print(post.postImgFileName)
    
    // delete database post
    ref.removeValue(completionBlock: { (err, ref) in
        if let _ = err {
            return
        }
        
        // delete storage post image
        let delRef = Storage.storage().reference().child("posts").child(post.postImgFileName)
        delRef.delete(completion: { (err) in
            if let _ = err {
                showErr(info: NSLocalizedString("failtoRemovePost", comment: ""), subInfo: tryLater)
                return
            }
        
            showSuccess(info: NSLocalizedString("successDeletePost", comment: ""), subInfo: "")
            
            // notify refresh
            NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
        })
    })
}

func unfollow(currentUserId: String, targetUid: String){
    //Unfollow
    Database.database().reference().child("following").child(currentUserId).child(targetUid).removeValue { (err, ref) in
        if let _ = err {
            showErr(info: NSLocalizedString("failtoUnfollow", comment: ""), subInfo: tryLater)
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
            showErr(info: NSLocalizedString("failtoHide", comment: ""), subInfo: tryLater)
            return
        }
        showSuccess(info: NSLocalizedString("successHide", comment: ""), subInfo: "")
        
        NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
    }
}

func reportPost(post: Post, reason: String) {
    guard let uid = Auth.auth().currentUser?.uid else {return}
    guard let postID = post.id else {return}
    let values = ["reporterID": uid, "reportReason":reason]
    Database.database().reference().child("report").child(postID).updateChildValues(values) { (err, _) in
        if let _ = err {
            showErr(info: NSLocalizedString("failtoReport", comment: ""), subInfo: tryLater)
            return
        }
        showSuccess(info: NSLocalizedString("successReport", comment: ""), subInfo: "")
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
                showErr(info: NSLocalizedString("failtoBlockUser", comment: ""), subInfo: tryLater)
                return
            }
            unfollow(currentUserId: userB, targetUid: userA)
            unfollow(currentUserId: userA, targetUid: userB)
            showSuccess(info: NSLocalizedString("successBlockedUser", comment: ""), subInfo: "")
        })
    })
    alertView.showWarning(NSLocalizedString("sureBlockUser", comment: ""), subTitle: NSLocalizedString("blockResult", comment: ""), closeButtonTitle: NSLocalizedString("cancel", comment: ""))
}

// userA blocks userB
func unblock(userA: String, userB: String){
    Database.database().reference().child("block").child(userB).child(userA).removeValue { (err, _) in
        if let _ = err {
            showErr(info: NSLocalizedString("failtoUnblock", comment: ""), subInfo: tryLater)
            return
        }
    }
}
