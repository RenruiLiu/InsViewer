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

class CommentInputAccessoryView: UIView, UITextViewDelegate {
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    fileprivate let submitBtn: UIButton = {
        let submitBtn = UIButton(type: .system)
        submitBtn.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        submitBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitBtn.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return submitBtn
    }()
    
    fileprivate let commentextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 18)
        return tv
    }()
    
    fileprivate func setuplineSeparatorView(){
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: 0, height: 1)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        
        addSubview(submitBtn)
        addSubview(commentextView)
        submitBtn.anchor(top: topAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: rightAnchor, paddingRight: 12, width: 50, height: 50)
        commentextView.delegate = self
        commentextView.anchor(top: topAnchor, paddingTop: 8, bottom: safeAreaLayoutGuide.bottomAnchor, paddingBottom: 8, left: leftAnchor, paddingLeft: 12, right: submitBtn.leftAnchor, paddingRight: 0, width: 0, height: 0)

        setuplineSeparatorView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // submit comment
    @objc fileprivate func handleSubmit(){
        guard let commentText = commentextView.text else {return}
        delegate?.didSubmit(for: commentText)
    }
    
    func clearCommentTextView(){
        // dismiss keyboard and clean the textfield
        commentextView.resignFirstResponder()
        commentextView.text = ""
        commentextView.showPlaceholderLabel(show: true)
    }
    
    override var intrinsicContentSize: CGSize {return .zero}
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            commentextView.showPlaceholderLabel(show: true)
        } else {
            commentextView.showPlaceholderLabel(show: false)
        }
    }
}
