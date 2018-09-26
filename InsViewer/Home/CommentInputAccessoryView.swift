//
//  CommentInputAccessoryView.swift
//  InsViewer
//
//  Created by Renrui Liu on 26/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}

class CommentInputAccessoryView: UIView {
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    fileprivate let submitBtn: UIButton = {
        let submitBtn = UIButton(type: .system)
        submitBtn.setTitle("Submit", for: .normal)
        submitBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitBtn.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return submitBtn
    }()
    
    fileprivate let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Comment"
        return textField
    }()
    
    fileprivate func setuplineSeparatorView(){
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 0, height: 1)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(submitBtn)
        addSubview(commentTextField)
        commentTextField.anchor(top: topAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: leftAnchor, paddingLeft: 12, right: submitBtn.leftAnchor, paddingRight: 0, width: 0, height: 0)
        submitBtn.anchor(top: topAnchor, paddingTop: 0, bottom: bottomAnchor, paddingBottom: 0, left: nil, paddingLeft: 0, right: rightAnchor, paddingRight: 12, width: 50, height: 0)
        setuplineSeparatorView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // submit comment
    @objc fileprivate func handleSubmit(){
        guard let commentText = commentTextField.text else {return}
        delegate?.didSubmit(for: commentText)
    }
    
    func clearCommentTextfield(){
        // dismiss keyboard and clean the textfield
        commentTextField.resignFirstResponder()
        commentTextField.text = ""
    }
}
