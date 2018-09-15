//
//  HomeViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 14/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

// TODO:
//1. home feed is not in right time order
//2. post time
//____________________________________________________________________________________

import UIKit
import Firebase

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let cellId = "cellId"
    //____________________________________________________________________________________

    fileprivate func setupNavigationItems(){
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
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
        cell.post = posts[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // top bar + image + bottom tool bar + caption & comment
        var height: CGFloat = (40 + 8 + 8) + view.frame.width
        height = height + 50 + 60
        return CGSize(width: view.frame.width, height: height)
    }
    
    //____________________________________________________________________________________
    
    var posts = [Post]()
    fileprivate func fetchPosts(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        // fetch user's posts from the user id
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
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
                let post = Post(user: user,dictionary: dictionary)
                self.posts.append(post)
            })
            self.posts.sort(by: { (p1, p2) -> Bool in
                return p1.creationData.compare(p2.creationData) == .orderedDescending
            })
            
            // finished and reload the view
            self.collectionView?.reloadData()
        }) { (err) in
            print("Failed to fetch ordered posts:", err)
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
    
    fileprivate func fetchAllPosts(){
        fetchPosts()
        fetchFollowingUserPosts()
    }
    
    @objc func handleUpdateFeed(){
        handleRefresh()
    }
}
