//
//  UserProfilePhotoCell.swift
//  InsViewer
//
//  Created by Renrui Liu on 14/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class UserProfilePhotoCell: UICollectionViewCell {
    
    var post: Post? {
        didSet{
            // after got the url for each cell, for each cell, create a thread to fetch the image from url and load it respectively
            guard let imgUrl = post?.imageUrl else {return}
            photoImgView.loadImage(urlString: imgUrl)
        }
    }
    let photoImgView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        addSubview(photoImgView)
        photoImgView.anchor(top: topAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
