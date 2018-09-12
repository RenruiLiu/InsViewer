//
//  UserProfileHeader.swift
//  InsViewer
//
//  Created by Renrui Liu on 12/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class UserProfileHeader: UICollectionViewCell {

    // fetch user data
    var user: UserProfile?{
        didSet {
            // setup the profile image right after got the user data
            setupProfileImg()
            usernameLabel.text = user?.username
        }
    }
    
    //____________________________________________________________________________________
    let profileImageView: UIImageView = {
        let imgview = UIImageView()
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
    let editProfileBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Edit Profile", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        return btn
    }()
    
    
    //____________________________________________________________________________________
    //functions
    
    fileprivate func setupProfileImg(){
        //
        guard let profileImgUrl = user?.profileImgUrl else {return} //get the string(Url)
        guard let url = URL(string: profileImgUrl) else {return} // cast the string url to URL
        
        //URLSession will open a background thread to download whatever in the url
        // and can do something after the response is returned
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            // check err then construct the img using the data
            if let err = err{
                print("Failed to fetch profile image:", err)
                return
            }
            
            // successfully got the data (HTTP Code 200)
            guard let data = data else {return}
            let img = UIImage(data: data)
            
            // get back onto the main UI thread, otherwise it stays on URLSession background thread
            DispatchQueue.main.async {
                self.profileImageView.image = img
            }
        }.resume()
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
        addSubview(editProfileBtn)
        editProfileBtn.anchor(top: postsLabel.bottomAnchor, paddingTop: 2, bottom: nil, paddingBottom: 0, left: postsLabel.leftAnchor, paddingLeft: 0, right: followingLabel.rightAnchor, paddingRight: 0, width: 0, height: 34)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
