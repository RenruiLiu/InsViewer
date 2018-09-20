//
//  MeViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 10/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate, HomePostCellDelegate {

    //properities
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    var userId: String?
    var isGridView = true
    var isListView = false

    //____________________________________________________________________________________
    //set up collection view cells
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isGridView || isListView {
            return posts.count //number of items in collection view section
        } else {
            return savedPosts.count
        }
        
    }
    // set up the custom cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // once the collectionView is rendering the last post in posts, fetch some more posts
        if indexPath.item == self.posts.count - 1 && !isFinishedPaging {
            paginatePosts()
        }

        if isGridView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.item]
            return cell
        } else if isListView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = savedPosts[indexPath.item]
            cell.delegate = self
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            //size for listView
            // [top bar + image] + [bottom tool bar + caption & comment]
            var height: CGFloat = (40 + 8 + 8) + view.frame.width
            height = height + 50 + 60
            return CGSize(width: view.frame.width, height: height)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.delegate = self
        return header
    }
    // setup the size of the header of collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isGridView{
            // jump to post VC
            let postController = PostViewController(collectionViewLayout: UICollectionViewFlowLayout())
            postController.post = posts[indexPath.item]
            navigationController?.pushViewController(postController, animated: true)
        }
    }

    //____________________________________________________________________________________
    // logout from navigation bar button
    fileprivate func setupLogoutBtn(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do{
                try Auth.auth().signOut()
                // present login controller after the user logged out
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutError {
                print("Failed to logout:",signOutError)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController,animated: true, completion: nil)
    }
    
    //____________________________________________________________________________________
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        //provide a custom collection header
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        // register two cells in one controller: grid and list
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        setupLogoutBtn()
        
        //receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoViewController.updateFeedNotificationName, object: nil)
        
        // fetch user and posts
        fetchUser()
    }
    
    //____________________________________________________________________________________
    var user: UserProfile? // a User object for passing around
    
    fileprivate func fetchUser(){
        
        // fetch the searched user or current user
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            
            //reload the  when all data is fetched
            self.collectionView?.reloadData()
            self.paginatePosts()
        }
    }
    
    // fetch saved
    var savedPosts = [Post]()
    fileprivate func fetchSaved(){
        var userIds = [String]()
        var postIds = [String]()
        
        // gather userIds and postIds
        guard let uid = self.user?.uid else {return}
        let getIDsRef = Database.database().reference().child("save_post").child(uid)
        let query = getIDsRef.queryOrderedByKey()
        query.observeSingleEvent(of: .value) { (snapshot) in
            let dictionary = snapshot.value as? [String:Any]
            dictionary?.forEach({ (key,value) in
                guard let dic = value as? [String:String] else {return}
                postIds.append(key)
                userIds.append(dic["userId"] ?? "")
            })
            
            // use userID and postID to fetch saved posts
            var i = 0
            while i < userIds.count{
                self.fetchPostsWithUserIDPostID(userID: userIds[i], postID: postIds[i])
                i += 1
            }
        }
        
    }
    
    fileprivate func fetchPostsWithUserIDPostID(userID: String, postID: String){
        
        // get post
        let getPostRef = Database.database().reference().child("posts")

        getPostRef.child(userID).child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                
                // get user
                let ref = Database.database().reference().child("users").child(userID)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dict = snapshot.value as? [String: Any] else {return}
                    let user = UserProfile(uid: userID, dict: dict)
                    var post = Post(user: user, dictionary: dictionary)
                    post.id = postID
                    
                    // see if it is liked
                    // check [likes - postId - CurrentUserId], if has value 1, then set the post.hasLike = true
                    guard let currentUserUID = Auth.auth().currentUser?.uid else {return}
                    Database.database().reference().child("likes").child(postID).child(currentUserUID).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let value = snapshot.value as? Int, value == 1 {
                            post.hasLiked = true
                        } else {post.hasLiked = false}
                        
                        post.hasSaved = true
                        self.savedPosts.append(post)
                        self.savedPosts.sort(by: { (p1, p2) -> Bool in
                            return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                        })
                        
                        self.collectionView.reloadData()
                    })
                })
            })
    }
    
    // fetch posts
    var posts = [Post]()
    var isFinishedPaging = false
    
    fileprivate func paginatePosts(){
        guard let uid = self.user?.uid else {return}
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrderedByKey()
        
        if posts.count > 0 {
            let value = posts.last?.id
            // let the query starts at every fourth member
            query = query.queryEnding(atValue: value)
        }
        
        // query only 4 posts from the last of list
        // observer every single node in posts - uid, the key is postId
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in

            guard let user = self.user else {return}
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            allObjects.reverse() // reverse 4 posts like: [6,7,8,9] -> [9,8,7,6]
            
            if allObjects.count < 4{
                // if we can't fetch 4 posts from database, means that paging is finshed
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 {
                // remove the first duplucated post in every 4 posts
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String:Any] else {return}
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
            })
            
            // 4 posts are fetched, now reload the page
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to paginate for posts:",err)
        }
    }
    
    //____________________________________________________________________________________
    // change to grid / list view
    
    func didChangeToGridView() {
        isGridView = true
        isListView = false
        collectionView?.reloadData()
    }
    func didChangeToListView() {
        isGridView = false
        isListView = true
        collectionView?.reloadData()
    }
    func didChangeToSavedView() {
        // fetch saved posts
        self.fetchSaved()
        isGridView = false
        isListView = false
        collectionView.reloadData()
    }
    
    //____________________________________________________________________________________
    // comment // introducing buttons in userprofile view need to confirm protocal first, and then implement methods along with delegate
    // and also a proper post structure
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
    
    
    //____________________________________________________________________________________
    // refresh
    
    @objc func handleUpdateFeed(){
        
        isFinishedPaging = false
        posts.removeAll()
        fetchUser()
    }
    
    // save
    func didSave(for cell: HomePostCell) {
        
        guard let indexPath = collectionView?.indexPath(for: cell) else {return}
        var post = self.posts[indexPath.item]
        
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
                self.posts[indexPath.item] = post
                self.collectionView?.reloadItems(at: [indexPath])
            }
        } else {
            // save
            let values = ["userId": targetUID]
            
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to save this post:",err)
                }
                
                post.hasSaved = true
                self.posts[indexPath.item] = post
                self.collectionView?.reloadItems(at: [indexPath])
                print("Successfully save the post into database")
            }
        }
    }
}

