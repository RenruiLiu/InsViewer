//
//  UserSearchCell.swift
//  InsViewer
//
//  Created by Renrui Liu on 14/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class UserSearchCell: UICollectionViewCell {
    
    var user: UserProfile? {
        didSet{
            usernameLabel.text = user?.username
            guard let profileImageUrl = user?.profileImgUrl else {return}
            profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .gray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50 / 2
        return iv
    }()
    let usernameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Username"
        lb.font = UIFont.boldSystemFont(ofSize: 14)
        return lb
    }()
    
    //____________________________________________________________________________________

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        
        profileImageView.anchor(top: nil, paddingTop: 0, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 8, right: nil, paddingRight: 0, width: 50, height: 50)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        usernameLabel.anchor(top: topAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: profileImageView.rightAnchor, paddingLeft: 8, right: rightAnchor, paddingRight: 0, width: 0, height: 0)
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(separatorView)
        separatorView.anchor(top: nil, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: usernameLabel.leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 0, height: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
