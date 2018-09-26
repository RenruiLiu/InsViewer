//
//  CommentInputTextView.swift
//  InsViewer
//
//  Created by Renrui Liu on 26/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {
    
    fileprivate let placeholderLabel: UILabel = {
        let lb = UILabel()
        lb.text =  "Enter Comment"
        lb.textColor = UIColor.lightGray
        return lb
    }()
    
    func showPlaceholderLabel(show: Bool){
        if show {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, paddingTop: 8, bottom: bottomAnchor, paddingBottom: 0, left: leftAnchor, paddingLeft: 8, right: rightAnchor, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
