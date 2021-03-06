//
//  UserProfileHeader.swift
//  InsViewer
//
//  Created by Renrui Liu on 12/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    var delegate: UserProfileHeaderDelegate?
    var following = 0 as Int

    // fetch user data
    var user: UserProfile?{
        didSet {
            // setup the profile image right after got the user data
            guard let profileImageUrl = user?.profileImgUrl else {return}
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
            
            // change the follow / edit button
            setupEditFollowBtn()
            getheadNumbers()
        }
    }
    
    fileprivate func getheadNumbers(){
        guard let uid = user?.uid else {return}
        var count = "0"
        // following
        let ref = Database.database().reference().child("following").child(uid)
        ref.observe(.value, with: { (snapshot) in
            count = String(snapshot.childrenCount)
            let attributedText = NSMutableAttributedString(string: count + "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: NSLocalizedString("following", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            self.followingLabel.attributedText = attributedText
        }) { (err) in
            print("Failed to fetch following number",err)
        }
        // follower
        let ref1 = Database.database().reference().child("followers").child(uid)
        ref1.observe(.value, with: { (snapshot) in
            count = String(snapshot.childrenCount)
            let attributedText = NSMutableAttributedString(string: count + "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: NSLocalizedString("follower", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            self.followersLabel.attributedText = attributedText
        }) { (err) in
            print("Failed to fetch follower number",err)
        }
        // posts
        let ref2 = Database.database().reference().child("posts").child(uid)
        ref2.observe(.value, with: { (snapshot) in
            count = String(snapshot.childrenCount)
            let attributedText = NSMutableAttributedString(string: count + "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: NSLocalizedString("post", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            self.postsLabel.attributedText = attributedText
        }) { (err) in
            print("Failed to fetch posts number",err)
        }
    }

    //____________________________________________________________________________________
    let profileImageView: CustomImageView = {
        let imgview = CustomImageView()
        imgview.layer.cornerRadius = 80/2 // make it round
        imgview.clipsToBounds = true
        return imgview
    }()
    
    lazy var gridBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        btn.addTarget(self, action: #selector(handleGridView), for: .touchUpInside)
        return btn
    }()
    lazy var listBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        btn.addTarget(self, action: #selector(handleListView), for: .touchUpInside)
        return btn
    }()
    lazy var bookMarkBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        btn.addTarget(self, action: #selector(handleSavedView), for: .touchUpInside)
        return btn
    }()
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("username", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0 //use any many as possible lines
        label.textAlignment = .center
        return label
    }()
    let followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    // added lazy var to handle any change to the properties of the view
    lazy var editProfileFollowBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("editProfile", comment: ""), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 5
        btn.addGestureRecognizer(longPress)
        return btn
    }()
    
    
    //____________________________________________________________________________________
    //functions
    
    fileprivate var isLoggingOut = true
    @objc func handleLongPress(){
        if isLoggingOut {
            print("logging out")
            do{
                try Auth.auth().signOut()
                isLoggingOut = false
                print("logged out")
            } catch let signOutError {
                print("Failed to logout:",signOutError)
            }
        }

    }
    
    @objc func handleEditProfileFollow(){
        // execute edit [profile / follow / unfollow]
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {return} // current logged in user
        guard let userId = user?.uid else {return} // searched user
        
        // perform Unfollow
        if editProfileFollowBtn.titleLabel?.text == NSLocalizedString("unfollow", comment: "") {
            
            unfollow(currentUserId: currentUserId, targetUid: userId)
            self.setupFollowStyle()
            
        } else if editProfileFollowBtn.titleLabel?.text == NSLocalizedString("follow", comment: "") {
            
            // get list of users who blocked the current user
            var blockList = [String]()
            
            Database.database().reference().child("block").child(currentUserId).observeSingleEvent(of: .value) { (snapshot) in
                let dict = snapshot.value as? [String:Any] ?? [:]
                for key in Array(dict.keys) {
                    blockList.append(key)
                }
                
                // check if the current user blocked the profile user
                var blockList1 = [String]()
                Database.database().reference().child("block").child(userId).observeSingleEvent(of: .value) { (snapshot) in
                    let dict = snapshot.value as? [String:Any] ?? [:]
                    for key in Array(dict.keys) {
                        blockList1.append(key)
                    }

                    // if the profile user is blocked by the current user
                    if blockList1.contains(currentUserId) {
                        showWarning(info: NSLocalizedString("cannotFollow", comment: ""), subInfo: NSLocalizedString("unblockBeforeFollow", comment: ""))
                        return
                    }
        
                    // if the current user is blocked by the profile user
                    if blockList.contains(userId) {
                        showErr(info: NSLocalizedString("cannotFollow", comment: ""), subInfo: NSLocalizedString("blockedByUser", comment: ""))
                        return
                    }
                
                    // perform Follow
                    follow(userA: currentUserId, userB: userId) {(result) in
                        if result {
                            print("Successfully followed user:", self.user?.username ?? "")
                            // change UI
                            self.editProfileFollowBtn.setTitle(NSLocalizedString("unfollow", comment: ""), for: .normal)
                            self.editProfileFollowBtn.backgroundColor = .white
                            self.editProfileFollowBtn.setTitleColor(.black, for: .normal)
                        }
                    }
                }
            }
        } else {
            // Edit profile
            guard let user = user else {return}
            delegate?.presentEditProfileVC(user: user)
        }
    }
    
    fileprivate func setupEditFollowBtn(){
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        // check current user profile or searched user
        if userId == currentUserId {
            //
        } else {
            // check if following
            Database.database().reference().child("following").child(currentUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
    
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    // check it's following, set "Unfollow" title
                    self.editProfileFollowBtn.setTitle(NSLocalizedString("unfollow", comment: ""), for: .normal)
                } else {
                    // check if not following, show follow UI
                    self.setupFollowStyle()
                }
            }) { (err) in
                    print("Failed to check if following:",err)
            }
        }
    }
    
    fileprivate func setupFollowStyle(){
        self.editProfileFollowBtn.setTitle(NSLocalizedString("follow", comment: ""), for: .normal)
        self.editProfileFollowBtn.backgroundColor = .mainBlue()
        self.editProfileFollowBtn.setTitleColor(.white, for: .normal)
        self.editProfileFollowBtn.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    fileprivate func setupBottomToolbar(){
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        let stackView = UIStackView(arrangedSubviews: [gridBtn,listBtn,bookMarkBtn])
        
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        addSubview(stackView)
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.anchor(top: nil, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 0, height: 50)
        topDividerView.anchor(top: stackView.topAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 0, height: 1)
        bottomDividerView.anchor(top: stackView.bottomAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 0, height: 1)
    }
    
    fileprivate func setupUserStatsView(){
        let stackView = UIStackView(arrangedSubviews: [postsLabel,followersLabel,followingLabel])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, paddingTop: 12, bottom: nil, paddingBottom: 0, left: profileImageView.rightAnchor, paddingLeft: 12, right: rightAnchor, paddingRight: 12, width: 0, height: 50)
    }
    
    @objc func handleListView(){
        // change colors for buttons
        listBtn.tintColor = .mainBlue()
        bookMarkBtn.tintColor = UIColor(white: 0, alpha: 0.2)
        gridBtn.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    @objc func handleGridView(){
        // change colors
        bookMarkBtn.tintColor = UIColor(white: 0, alpha: 0.2)
        listBtn.tintColor = UIColor(white: 0, alpha: 0.2)
        gridBtn.tintColor = .mainBlue()
        delegate?.didChangeToGridView()
    }
    @objc func handleSavedView(){
        
        //the user can only delete his own posts
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        if currentUserId != user?.uid {return}
        
        listBtn.tintColor = UIColor(white: 0, alpha: 0.2)
        gridBtn.tintColor = UIColor(white: 0, alpha: 0.2)
        bookMarkBtn.tintColor = .mainBlue()
        delegate?.didChangeToSavedView()
    }
    
    
    //____________________________________________________________________________________
    // init this userprofile header, just like viewdidloaded
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, paddingTop: 12, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 12, right: nil, paddingRight: 0, width: 80, height: 80)
        //
        setupBottomToolbar()
        //
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 4, bottom: gridBtn.topAnchor, paddingBottom: 0, left: leftAnchor, paddingLeft: 24, right: nil, paddingRight: 0, width: 0, height: 0)
        //
        setupUserStatsView()
        //
        addSubview(editProfileFollowBtn)
        editProfileFollowBtn.anchor(top: postsLabel.bottomAnchor, paddingTop: 2, bottom: nil, paddingBottom: 0, left: postsLabel.leftAnchor, paddingLeft: 0, right: followingLabel.rightAnchor, paddingRight: 0, width: 0, height: 34)
        
        //
        let tapFollowing = UITapGestureRecognizer(target: self, action: #selector(didTapFollowing))
        let tapFollower = UITapGestureRecognizer(target: self, action: #selector(didTapFollower))
        followingLabel.isUserInteractionEnabled = true
        followersLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(tapFollowing)
        followersLabel.addGestureRecognizer(tapFollower)
    }
    
    @objc func didTapFollowing(){
        let searchVC = UserSearchViewController(collectionViewLayout: UICollectionViewFlowLayout())
        searchVC.userId = user?.uid
        searchVC.mode = 2
        
        let navEditorViewController: UINavigationController = UINavigationController(rootViewController: searchVC)
        UIApplication.shared.keyWindow?.rootViewController?.present(navEditorViewController, animated: true)
    }
    @objc func didTapFollower(){
        let searchVC = UserSearchViewController(collectionViewLayout: UICollectionViewFlowLayout())
        searchVC.userId = user?.uid
        searchVC.mode = 1
        
        let navEditorViewController: UINavigationController = UINavigationController(rootViewController: searchVC)
        UIApplication.shared.keyWindow?.rootViewController?.present(navEditorViewController, animated: true)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
