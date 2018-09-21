//
//  PostViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 20/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class PostViewController: UICollectionViewController, HomePostCellDelegate, UICollectionViewDelegateFlowLayout {

    let cellId = "cellId"
    
    var post: Post?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .white
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    //____________________________________________________________________________________

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell // cast it to custom cell class to allow us to use methods in that class
        
        // by confirming the homePostCellDelegate, this allows every cell has the delegate to perform [comment]
        cell.delegate = self
        cell.post = post
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // top bar + image + bottom tool bar + caption & comment
        var height: CGFloat = (40 + 8 + 8) + view.frame.width
        height = height + 50 + 60
        return CGSize(width: view.frame.width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //____________________________________________________________________________________
    // comment
    func didTapComment(post: Post) {
        let commentsController = CommentsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    // like
    func didLike(for cell: HomePostCell) {
        // get the indexpath of liked post and so can get the post
        guard let postId = post!.id else {return}
        
        // Firebase operation
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = [uid: post!.hasLiked == true ? 0:1]
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (err, _ref) in
            if let err = err {
                print("Failed to like post:",err)
            }
            print("Successfully liked post")
            self.post!.hasLiked = !self.post!.hasLiked
            self.collectionView.reloadData()
        }
    }
    
    func didPressOption(post: Post) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { (_) in
            
            //deletion
            guard let uid = Auth.auth().currentUser?.uid else {return}
            guard let postId = post.id else {return}
            
            
            Database.database().reference().child("posts").child(uid).child(postId).removeValue(completionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to remove this post",err)
                }
                // notify refresh
                
                NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
            })
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController,animated: true, completion: nil)
    }
    
    // save
    func didSave(for cell: HomePostCell) {
        
        guard var post = post else {return}
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        let targetUID = post.user.uid
        guard let postId = post.id else {return}
        
        let ref = Database.database().reference().child("save_post").child(currentUserId).child(postId)
        
        if post.hasSaved {
            // unsave
            ref.removeValue { (err, _) in
                if let err = err {
                    print("Failed to unsave: ",err)
                }
                post.hasSaved = false
                self.collectionView?.reloadData()
            }
        } else {
            // save
            let values = ["userId": targetUID]
            
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to save this post:",err)
                }
                
                post.hasSaved = true
                self.collectionView?.reloadData()
                print("Successfully save the post into database")
            }
        }
    }
    
    // share
    func didShare(for cell: HomePostCell) {
        print("share")
        let activityVC = UIActivityViewController(activityItems: [cell.captionLabel.text,cell.photoImgView.image], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        present(activityVC,animated: true,completion: nil)
    }

}
