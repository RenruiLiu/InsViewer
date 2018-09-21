//
//  EditProfileViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 21/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase


class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var didChangedPhoto = false
    
    var user: UserProfile? {
        didSet{
            nameTextField.text = user?.username
            // load img
            guard let urlString = user?.profileImgUrl else {return}
            guard let url = URL(string: urlString) else {return}
            
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                if let err = err {
                    print("Failed to fetch post image:", err)
                    return
                }
                guard let imageData = data else {return}
                let photoImage = UIImage(data: imageData)
                DispatchQueue.main.async {
                    self.profileImageButton.setImage(photoImage, for: .normal)
                }
            }.resume()
        }
    }
    
    let profileImageButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 120 / 2
        //iv.loadImage(urlString: )
        btn.contentMode = .scaleAspectFill
        btn.clipsToBounds = true
        btn.layer.masksToBounds = true
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 3
        btn.addTarget(self, action: #selector(handleChangeProfileImage), for: .touchUpInside)
        return btn
    }()
    
    let nameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Name"
        lb.font = UIFont.boldSystemFont(ofSize: 14)
        return lb
    }()
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    let passwordLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Password"
        lb.font = UIFont.boldSystemFont(ofSize: 14)
        return lb
    }()
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your password"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        return tf
    }()
    let newPasswordLabel: UILabel = {
        let lb = UILabel()
        lb.text = "New Password"
        lb.font = UIFont.boldSystemFont(ofSize: 14)
        return lb
    }()
    let newPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your new password"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        return tf
    }()
    
    
    fileprivate func setupViews(){
        // profile image
        view.addSubview(profileImageButton)
        profileImageButton.anchor(top: view.topAnchor, paddingTop: 100, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: nil, paddingRight: 0, width: 120, height: 120)
        profileImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // name
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        nameLabel.anchor(top: profileImageButton.bottomAnchor, paddingTop: 12, bottom: nil, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 12, right: nameTextField.leftAnchor, paddingRight: 4, width: 100, height: 40)
        nameTextField.anchor(top: profileImageButton.bottomAnchor, paddingTop: 12, bottom: nil, paddingBottom: 0, left: nameLabel.rightAnchor, paddingLeft: 4, right: view.rightAnchor, paddingRight: 8, width: 0, height: 40)
        
        let line = UIView()
        line.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.addSubview(line)
        line.anchor(top: nameTextField.bottomAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: nameTextField.leftAnchor, paddingLeft: 0, right: nameTextField.rightAnchor, paddingRight: 0, width: 0, height: 1)
        
        //password
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        passwordLabel.anchor(top: line.bottomAnchor, paddingTop: 4, bottom: nil, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 12, right: passwordTextField.leftAnchor, paddingRight: 4, width: 100, height: 40)
        passwordTextField.anchor(top: line.bottomAnchor, paddingTop: 4, bottom: nil, paddingBottom: 0, left: passwordLabel.rightAnchor, paddingLeft: 4, right: view.rightAnchor, paddingRight: 8, width: 0, height: 40)
        
        let line1 = UIView()
        line1.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.addSubview(line1)
        line1.anchor(top: passwordTextField.bottomAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: passwordTextField.leftAnchor, paddingLeft: 0, right: passwordTextField.rightAnchor, paddingRight: 0, width: 0, height: 1)

        // new password
        view.addSubview(newPasswordLabel)
        view.addSubview(newPasswordTextField)
        newPasswordLabel.anchor(top: line1.bottomAnchor, paddingTop: 4, bottom: nil, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 12, right: newPasswordTextField.leftAnchor, paddingRight: 4, width: 100, height: 40)
        newPasswordTextField.anchor(top: line1.bottomAnchor, paddingTop: 4, bottom: nil, paddingBottom: 0, left: passwordLabel.rightAnchor, paddingLeft: 4, right: view.rightAnchor, paddingRight: 8, width: 0, height: 40)

        let line2 = UIView()
        line2.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.addSubview(line2)
        line2.anchor(top: newPasswordTextField.bottomAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: newPasswordTextField.leftAnchor, paddingLeft: 0, right: newPasswordTextField.rightAnchor, paddingRight: 0, width: 0, height: 1)

    }
    
    fileprivate func setupNavigationButtons(){
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
    }
    
    //____________________________________________________________________________________

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupViews()
        setupNavigationButtons()
        
    }
    
    //____________________________________________________________________________________

    // pick image
    @objc func handleChangeProfileImage(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.editedImage] as? UIImage{
            profileImageButton.setImage(img.withRenderingMode(.alwaysOriginal), for: .normal)
            didChangedPhoto = true
        }
        profileImageButton.layer.cornerRadius = profileImageButton.frame.width/2
        dismiss(animated: true, completion: nil)
    }
    
    // move to next: share photo
    @objc func handleSave(){
        //save
        if didChangedPhoto {
            uploadProfileImage()
        } else if nameTextField.text != user?.username {
            guard let profileImageURL = user?.profileImgUrl else {return}
            updateUser(username: nameTextField.text ?? "", profileImageURL: profileImageURL)
        } else if passwordTextField.text != nil && newPasswordTextField.text != nil {
            checkPassword(password: passwordTextField.text ?? "", newPassword: newPasswordTextField.text ?? "")
            return
        }
        print("if change password cant reach this")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func uploadProfileImage(){
        guard let image = self.profileImageButton.imageView?.image else {return}
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Failed to upload profile image:",err)
                return
            }
            storageRef.downloadURL(completion: { (downloadURL, err) in
                guard let profileImageURL = downloadURL?.absoluteString else {return}
                self.updateUser(username: self.nameTextField.text ?? "", profileImageURL: profileImageURL)
            })
        }
    }
    
    fileprivate func updateUser(username: String, profileImageURL: String){
        let values = ["username": username, "profileImageUrl": profileImageURL]
        guard let uid = self.user?.uid else {return}
        Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print("Failed to update user profile",err)
                return
            }
            print("Successfully edited user profile, please re-login to see update")
        })
    }
    
    fileprivate func checkPassword(password: String, newPassword: String){
        let user = Auth.auth().currentUser
        guard let email = user?.email else {return}
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user?.reauthenticate(with: credential, completion: { (err) in
            if let err = err {
                print("Failed to verify your password:",err)
                return
            }
            user?.updatePassword(to: newPassword, completion: { (err) in
                if let err = err {
                    print("Failed to setup new password:",err)
                    return
                }
                print("Successfully changed your password, please login again")
                do{
                    print("try to logout")
                    try Auth.auth().signOut()
                    self.dismissAndPresent()
                } catch let signOutError {
                    print("Failed to logout:",signOutError)
                }
            })
        })
    }
    
    fileprivate func dismissAndPresent(){
        weak var pvc = presentingViewController
        dismiss(animated: false, completion: {
            // present login controller after the user logged out
            let loginVC = LoginViewController()
            print("dismiss and present")
            let navController = UINavigationController(rootViewController: loginVC)
            pvc?.present(navController, animated: true)
        })
    }
}

