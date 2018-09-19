//
//  HomeViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 14/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

//____________________________________________________________________________________

import UIKit
import Firebase

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {

    let cellId = "cellId"

    //____________________________________________________________________________________

    fileprivate func setupNavigationItems(){
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    @objc func handleCamera(){
        let cameraController = CameraViewController()
        present(cameraController, animated: true, completion: nil)
    }
    
    //____________________________________________________________________________________
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        //receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoViewController.updateFeedNotificationName, object: nil)
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        setupNavigationItems()
        
        fetchAllPosts()
        setupRefresher()
    }
    
    //____________________________________________________________________________________
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell // cast it to custom cell class to allow us to use methods in that class
        
        // by confirming the homePostCellDelegate, this allows every cell has the delegate to perform [comment]
        cell.delegate = self
        
        if indexPath.item < posts.count {
            cell.post = posts[indexPath.item]
        } else {return cell}

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // top bar + image + bottom tool bar + caption & comment
        var height: CGFloat = (40 + 8 + 8) + view.frame.width
        height = height + 50 + 60
        return CGSize(width: view.frame.width, height: height)
    }
    
    //____________________________________________________________________________________
    
    fileprivate func fetchAllPosts(){
        fetchPosts()
        fetchFollowingUserPosts()
    }
    
    var posts = [Post]()
    fileprivate func fetchPosts(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        // fetch user's posts from the user id
        Database.fetchUserWithUID(uid: uid) { (user) in
            
            self.fetchPostsWithUser(user: user)
        }
    }
    
    fileprivate func fetchFollowingUserPosts(){
        // fetch following users' ids
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userIdsDictionary = snapshot.value as? [String: Any] else {return}
            userIdsDictionary.forEach({ (key,value) in
                
                // and get their posts by using thier ids(key)
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    
                    self.fetchPostsWithUser(user: user)
                })
            })
        }) { (err) in
            print("Failed to fetch following user ids :",err)
        }
        //
    }
    
    fileprivate func fetchPostsWithUser(user: UserProfile){
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        // fetch post in right order // implement some pagination of data??
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // stop the refresh controller // but why here??
            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let dictionaries = snapshot.value as? [String:Any] else {return}
            dictionaries.forEach({ (key,value) in
                guard let dictionary = value as? [String: Any] else {return}
                
                // construct post with userprofile
                var post = Post(user: user,dictionary: dictionary)
                post.id = key
                guard let uid = Auth.auth().currentUser?.uid else {return}
                // see if it is liked
                // check [likes - postId - CurrentUserId], if has value 1, then set the post.hasLike = true
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {post.hasLiked = false}
                    
                    self.posts.append(post)
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    // finished and reload the view
                    self.collectionView?.reloadData()
                    
                }, withCancel: { (err) in
                    print("Failed to fetch like info for post:",err)
                })
            })
        }) { (err) in
            print("Failed to fetch ordered posts:", err)
        }
    }

    
    //____________________________________________________________________________________
    // refresh
    fileprivate func setupRefresher(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    @objc func handleRefresh(){
        posts.removeAll()
        fetchAllPosts()
    }
    
    @objc func handleUpdateFeed(){
        handleRefresh()
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
        guard let indexPath = collectionView?.indexPath(for: cell) else {return}
        var post = self.posts[indexPath.item]
        guard let postId = post.id else {return}
        
        // Firebase operation
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = [uid: post.hasLiked == true ? 0:1]
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (err, _ref) in
            if let err = err {
                print("Failed to like post:",err)
            }
            print("Successfully liked post")
            post.hasLiked = !post.hasLiked
            self.posts[indexPath.item] = post
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
    
    func didPressOption(post: Post) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {return} // current logged in user
        let targetUid =  post.user.uid
        
        // if it's user self, then skip
        if currentUserId == targetUid {return}
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { (_) in
            
            unfollow(currentUserId: currentUserId, targetUid: targetUid)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController,animated: true, completion: nil)
    }

}
