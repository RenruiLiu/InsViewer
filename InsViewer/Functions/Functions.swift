//
//  Functions.swift
//  InsViewer
//
//  Created by Renrui Liu on 27/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation
import Firebase
import SCLAlertView


func showOptions(post: Post){
    guard let currentUserId = Auth.auth().currentUser?.uid else {return} // current logged in user
    let targetUid =  post.user.uid
    
    // if it's user self, then can delete the post
    if currentUserId == targetUid {
        //delete
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { (_) in
            deleteFromFirebase(post: post)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController,animated: true, completion: nil)
        
    } else {
        
        // 1.hide, 2.report other users' post, 3.unfollow, 4.block user
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Unfollow", style: .default, handler: { (_) in
            unfollow(currentUserId: currentUserId, targetUid: targetUid)
        }))
        
        alertController.addAction(UIAlertAction(title: "Hide", style: .default, handler: { (_) in
            hidePost(post: post)
        }))
        
        alertController.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (_) in
            
            // report alert
            let alertView = SCLAlertView()
            let textView = alertView.addTextView()
            alertView.addButton("Report", action: {
                var reason = "None"
                if textView.text != "" {reason = textView.text}
                reportPost(post: post, reason: reason)
            })
            alertView.showEdit("Reason", subTitle: "",closeButtonTitle: "Cancel")
        }))
        
        alertController.addAction(UIAlertAction(title: "Block this user", style: .destructive, handler: { (_) in
            print("block")
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController,animated: true, completion: nil)
    }
}

func sharePost(for cell: HomePostCell) {
    let activityVC = UIActivityViewController(activityItems: [cell.captionLabel.text,cell.photoImgView.image], applicationActivities: nil)
    activityVC.popoverPresentationController?.sourceView = UIApplication.shared.keyWindow?.rootViewController?.view
    UIApplication.shared.keyWindow?.rootViewController?.present(activityVC,animated: true,completion: nil)
}
