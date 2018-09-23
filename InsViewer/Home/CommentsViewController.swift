//
//  CommentsViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 16/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class CommentsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CommentDelegate {

    
    var post:Post?
    let cellId = "cellId"
    //____________________________________________________________________________________

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        fetchComments()
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
    var comments = [Comment]()
    fileprivate func fetchComments(){
        guard let postId = self.post?.id else {return   }
        let ref = Database.database().reference().child("comment").child(postId)
        ref.observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            guard let uid = dictionary["uid"] as? String else {return}
        
            Database.fetchUserWithUID(uid: uid, completion: { (user) in
                
                // cast comment data from firebase to Comment struct
                var comment = Comment(user: user, dictionary: dictionary)
                comment.id = snapshot.key
                comment.postId = postId
                self.comments.append(comment)
                
                self.collectionView?.reloadData()
            })
        }) { (err) in
            print("Failed to fetch comments",err)
        }
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
        
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        containerView.addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: containerView.topAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: containerView.leftAnchor, paddingLeft: 0, right: containerView.rightAnchor, paddingRight: 0, width: 0, height: 1)
        
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
                
                let alert = showAlert(title: "Failed to comment", text: "please try again later")
                self.present(alert, animated: true, completion: nil)
                print("Failed to insert comment into database",err)
            }
            print("Successfully inserted comment")
            // dismiss keyboard and clean the textfield
            self.commentTextField.resignFirstResponder()
            self.commentTextField.text = ""
        }
    }
    
    //____________________________________________________________________________________
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = self.comments[indexPath.item]
        cell.delegate = self
        cell.cellId = indexPath.item
        return cell
    }
    // size for each item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40+8+8, estimatedSize.height) // the height of profileImage or the height of text
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //____________________________________________________________________________________
    // Delete comment  //impletement you can't delete some else's comment
    func didDeleteComment(comment: Comment, cellId: Int) {
        guard let postId = post?.id else {return}
        guard let commentId = comment.id else {return}
        
        let ref = Database.database().reference().child("comment").child(postId).child(commentId)
        ref.removeValue { (err, _) in
            if let err = err {
                
                let alert = showAlert(title: "Failed to delete the comment", text: "please try again later")
                self.present(alert, animated: true, completion: nil)
                print("Failed to Delete current comment",err)
            }
            self.comments.remove(at: cellId)
            self.collectionView.reloadData()
        }
    }
    
    
}
