//
//  SharePhotoViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 13/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoViewController: UIViewController {
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    var selectedImg: UIImage?{
        didSet{
            self.imgView.image = selectedImg
        }
    }
    
    let imgView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .red
        iv.clipsToBounds = true
        return iv
    }()
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    fileprivate func setupImageAndTextViews(){
        let containerView = UIView()
        containerView.backgroundColor = .white
        //
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 0, height: 100)
        //
        containerView.addSubview(imgView)
        imgView.anchor(top: containerView.topAnchor, paddingTop: 8, bottom: containerView.bottomAnchor, paddingBottom: 8, left: containerView.leftAnchor, paddingLeft: 8, right: nil, paddingRight: 0, width: 84, height: 0)
        //
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, paddingTop: 0, bottom: containerView.bottomAnchor, paddingBottom: 0, left: imgView.rightAnchor, paddingLeft: 4, right: containerView.rightAnchor, paddingRight: 0, width: 0, height: 0)
    }
    
    //____________________________________________________________________________________
    // share photo & save to database
    @objc func handleShare(){
        // unable to share if no caption
        guard let caption = textView.text, caption.count > 0 else {return}
        guard let image = selectedImg else {return}
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else {return}//compression image
        // disable the share button to prevent duplication
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("posts").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                // enable the share button when a error occurs so the user can re-share it
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                
                let alert = showAlert(title: "Failed to share photo", text: "please try again later")
                self.present(alert, animated: true, completion: nil)
                print("Failed to upload data: ", err )
                return
            }
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else {return}
            print("Successfully uploaded post image:", imageUrl)
            self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
        }
    }
    
    // create a child node "posts" which contains all infomation of posts of users
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String){
        //
        guard let postImg = selectedImg else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let caption = textView.text else {return}
        //
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        // imgUrl - caption - imgWidth - imgHeight - creationDate
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImg.size.width, "imageHeight": postImg.size.height, "creationDate": Date().timeIntervalSince1970] as [String: Any]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                
                
                let alert = showAlert(title: "Failed to save your post", text: "please try again later")
                self.present(alert, animated: true, completion: nil)
                print("Failed to save post to Database", err)
                return
            }
            print("Successfully saved post to database")
            
            // refresh home page
            NotificationCenter.default.post(name: SharePhotoViewController.updateFeedNotificationName, object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }

    //____________________________________________________________________________________
    override var prefersStatusBarHidden: Bool {return true}
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        setupImageAndTextViews()
    }

}
