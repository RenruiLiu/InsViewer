//
//  CommentsViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 16/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class CommentsViewController: UICollectionViewController {
    
    var post:Post?
    
    //____________________________________________________________________________________

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comment"
        collectionView?.backgroundColor = .white
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        inputAccessoryView?.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        inputAccessoryView?.isHidden = true
    }
    
    //____________________________________________________________________________________
    // input
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Comment"
        return textField
    }()
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let submitBtn = UIButton(type: .system)
        submitBtn.setTitle("Submit", for: .normal)
        submitBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitBtn.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        containerView.addSubview(self.commentTextField)
        containerView.addSubview(submitBtn)
        self.commentTextField.anchor(top: containerView.topAnchor, paddingTop: 0, bottom: containerView.bottomAnchor, paddingBottom: 0, left: containerView.leftAnchor, paddingLeft: 12, right: submitBtn.leftAnchor, paddingRight: 0, width: 0, height: 0)
        submitBtn.anchor(top: containerView.topAnchor, paddingTop: 0, bottom: containerView.bottomAnchor, paddingBottom: 0, left: nil, paddingLeft: 0, right: containerView.rightAnchor, paddingRight: 12, width: 50, height: 0)
        return containerView
    }()
    // This inputAccessoryView will hold a input bar in the bottom
    override var inputAccessoryView: UIView?{
        get{
            return containerView
        }
    }
    override var canBecomeFirstResponder: Bool {return true}
    
    // submit comment
    @objc fileprivate func handleSubmit(){
        guard let postId = post?.id else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String : Any]
        
        // childByAutoId() creates a random id for creating a new node in comment tree
        // which means every comment is a new node containing its text, sender, creationDate etc.
        Database.database().reference().child("comment").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to insert comment into database",err)
            }
            print("Successfully inserted comment")
        }
    }
    
}
