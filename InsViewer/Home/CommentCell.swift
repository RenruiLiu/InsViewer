//
//  CommentCell.swift
//  InsViewer
//
//  Created by Renrui Liu on 17/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class CommentCell: PZSwipedCollectionViewCell {
    
    var delegate: CommentDelegate?
    var cellId: Int?
    
    var comment: Comment? {
        didSet{
            guard let comment = comment else {return}
            
            let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            let timeAgo = comment.creationDate.timeAgoDisplay()
            let posted = NSLocalizedString("posted", comment: "")
            attributedText.append(NSAttributedString(string: "    \(posted) " + timeAgo, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            textView.attributedText = attributedText
            
            profileImageView.loadImage(urlString: comment.user.profileImgUrl)
            
            checkCanDelete()
        }
    }
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40 / 2
        return iv
    }()
    
    fileprivate func setUpDeleteBtn(width: CGFloat){
        let btn = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: self.bounds.height)))
        btn.backgroundColor = UIColor.rgb(red: 255, green: 58, blue: 58)
        btn.setTitle("Delete", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(handleDeleteComment), for: .touchUpInside)
        self.revealView = btn
    }
    
    
    //____________________________________________________________________________________

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        addSubview(profileImageView)
        textView.anchor(top: topAnchor, paddingTop: 4, bottom: bottomAnchor, paddingBottom: 4, left: profileImageView.rightAnchor, paddingLeft: 4, right: rightAnchor, paddingRight: 4, width: 0, height: 0)
        profileImageView.anchor(top: topAnchor, paddingTop: 8, bottom: nil, paddingBottom: 0, left: leftAnchor, paddingLeft: 8, right: nil, paddingRight: 0, width: 40, height: 40)
        
        // At the begin of commentVC, comment variable is not set yet, so init revealView as nil
        self.revealView = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //current user [自己的comment + 自己post的comment]
    @objc func handleDeleteComment(){
        guard let comment = comment else {return}
        delegate?.didDeleteComment(comment: comment, cellId: cellId!)
    }
    
    fileprivate func checkCanDelete(){
        guard let postId = comment?.postId else {return}
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("posts").child(currentUserID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            
            // Check if it's the users' post, then the user can delete comments from anyone
            // Check if the comment is from the currentUser
            if dictionary[postId] != nil || self.comment?.uid == currentUserID {
                self.setUpDeleteBtn(width: self.bounds.width / 5)
            } else {self.setUpDeleteBtn(width: 0)}
        }
    }
}

