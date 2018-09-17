//
//  HomePostCell.swift
//  InsViewer
//
//  Created by Renrui Liu on 14/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class HomePostCell: UICollectionViewCell{
    
    var delegate: HomePostCellDelegate?
    
    var post: Post?{
        didSet{
            guard let postImgUrl = post?.imageUrl else {return}
            photoImgView.loadImage(urlString: postImgUrl)
            // setup home feed
            usernameLabel.text = post?.user.username
            guard  let profileImgUrl = post?.user.profileImgUrl else {return}
            userProfileImageView.loadImage(urlString: profileImgUrl)
            setupAttributedCaption()
            likeBtn.setImage(post?.hasLiked == true ? #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal): #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
 
    //____________________________________________________________________________________
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40 / 2
        return iv
    }()
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let optionsBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("•••", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    let photoImgView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        return iv
    }()
    lazy var likeBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return btn
    }()
    lazy var CommentBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return btn
    }()
    let SendMsgBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    let BookmarkBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return btn
    }()
    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate func setupActionBtns(){
        let stackView = UIStackView(arrangedSubviews: [likeBtn,CommentBtn,SendMsgBtn])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: photoImgView.bottomAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 8, right: nil, paddingRight: 0, width: 120, height: 50)
        
        addSubview(BookmarkBtn)
        BookmarkBtn.anchor(top: photoImgView.bottomAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 40, height: 50)
    }
    fileprivate func setupAttributedCaption(){
        guard let post = self.post else {return}
        
        //
        let attributedText = NSMutableAttributedString(string: post.user.username,attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " \(post.caption)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        let timeAgo = post.creationData.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgo, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.gray]))
        captionLabel.attributedText = attributedText
    }
    //____________________________________________________________________________________

    @objc func handleComment(){
        guard let post = post else {return}
        delegate?.didTapComment(post: post)
    }
 
    //____________________________________________________________________________________
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(optionsBtn)
        addSubview(photoImgView)
        addSubview(captionLabel)
        //
        userProfileImageView.anchor(top: topAnchor, paddingTop: 8, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 8, right: nil, paddingRight: 0, width: 40, height: 40)
        usernameLabel.anchor(top: topAnchor, paddingTop: 0, bottom: photoImgView.topAnchor, paddingBottom: 0, left: userProfileImageView.rightAnchor, paddingLeft: 8, right: optionsBtn.leftAnchor, paddingRight: 0, width: 0, height: 0)
        optionsBtn.anchor(top: topAnchor, paddingTop: 0, bottom: photoImgView.topAnchor, paddingBottom: 0, left: nil, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 44, height: 0)
        photoImgView.anchor(top: userProfileImageView.bottomAnchor, paddingTop: 8, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 0, height: 0)
        photoImgView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true // make it a square
        setupActionBtns()
        captionLabel.anchor(top: likeBtn.bottomAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: leftAnchor, paddingLeft: 8, right: rightAnchor, paddingRight: 8, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //____________________________________________________________________________________
    
    @objc fileprivate func handleLike(){
        delegate?.didLike(for: self)
    }
}
