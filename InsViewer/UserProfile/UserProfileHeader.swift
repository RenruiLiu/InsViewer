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

    // fetch user data
    var user: UserProfile?{
        didSet {
            // setup the profile image right after got the user data
            guard let profileImageUrl = user?.profileImgUrl else {return}
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
            
            // change the follow / edit button
            setupEditFollowBtn()
        }
    }
    
    //____________________________________________________________________________________
    let profileImageView: CustomImageView = {
        let imgview = CustomImageView()
        imgview.layer.cornerRadius = 80/2 // make it round
        imgview.clipsToBounds = true
        return imgview
    }()
    
    let gridBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return btn
    }()
    let listBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        return btn
    }()
    let bookMarkBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        return btn
    }()
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let postsLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0 //use any many as possible lines
        label.textAlignment = .center
        return label
    }()
    let followersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let followingLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    // added lazy var to handle any change to the properties of the view
    lazy var editProfileFollowBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Edit Profile", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return btn
    }()
    
    
    //____________________________________________________________________________________
    //functions
    @objc func handleEditProfileFollow(){
        // execute edit [profile / follow / unfollow]
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {return} // current logged in user
        guard let userId = user?.uid else {return} // searched user
        
        // perform Unfollow
        if editProfileFollowBtn.titleLabel?.text == "Unfollow" {
            
            Database.database().reference().child("following").child(currentUserId).child(userId).removeValue { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user:", err)
                    return
                }
                print("Successfully unfollowed user:", self.user?.username ?? "")
                // change UI
                self.setupFollowStyle()
            }
            
            
        } else {
            // perform Follow
            
            // access firebase tree: following -> currentuser -> [[user1 : 1],...]
            let ref = Database.database().reference().child("following").child(currentUserId)
            
            let values = [userId: 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to follow user: ", err)
                    return
                }
                print("Successfully followed user:", self.user?.username ?? "")
                // change UI
                self.editProfileFollowBtn.setTitle("Unfollow", for: .normal)
                self.editProfileFollowBtn.backgroundColor = .white
                self.editProfileFollowBtn.setTitleColor(.black, for: .normal)
            }

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
                    self.editProfileFollowBtn.setTitle("Unfollow", for: .normal)
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
        self.editProfileFollowBtn.setTitle("Follow", for: .normal)
        self.editProfileFollowBtn.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
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
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}