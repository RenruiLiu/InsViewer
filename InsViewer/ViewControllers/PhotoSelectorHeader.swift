//
//  PhotoSelectorHeader.swift
//  InsViewer
//
//  Created by Renrui Liu on 13/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class PhotoSelectorHeader: UICollectionViewCell {
    
    let photoImgView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImgView)
        photoImgView.anchor(top: topAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
