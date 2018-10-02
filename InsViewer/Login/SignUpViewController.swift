//
//  LoginViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 9/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    //____________________________________________________________________________________
    //properties
    let plusPhotoBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = NSLocalizedString("email", comment: "")
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = NSLocalizedString("username", comment: "")
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = NSLocalizedString("password", comment: "")
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    let signUpBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("signUp", comment: ""), for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149,green: 204,blue: 244)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    let checkBox: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("0", for: .normal)
        button.tintColor = .white
        button.setImage(#imageLiteral(resourceName: "uncheck").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCheck), for: .touchUpInside)
        return button
    }()
    let readEULA: UILabel = {
        let lb = UILabel()
        lb.text = NSLocalizedString("readAgree", comment: "")
        lb.font = lb.font.withSize(12)
        lb.textColor = .lightGray
        return lb
    }()
    let EULA: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("EULA", comment: ""), for: .normal)
        btn.titleLabel?.font = btn.titleLabel?.font.withSize(12)
        btn.addTarget(self, action: #selector(handleEULA), for: .touchUpInside)
        return btn
    }()
    
    //____________________________________________________________________________________
    //functions
    @objc func handleEULA(){
        let EULA_VC = EULAViewController()
        let navVC = UINavigationController(rootViewController: EULA_VC)
        navVC.isNavigationBarHidden = false
        present(navVC, animated: true)
    }
    
    @objc func handleCheck(){
        if checkBox.currentTitle == "1" {
            checkBox.setImage(#imageLiteral(resourceName: "uncheck").withRenderingMode(.alwaysOriginal), for: .normal)
            checkBox.setTitle("0", for: .normal)
        } else {
            checkBox.setImage(#imageLiteral(resourceName: "baseline_check_box_black_18dp").withRenderingMode(.alwaysOriginal), for: .normal)
            checkBox.setTitle("1", for: .normal)
        }
        handleTextInputChange()
    }
    
    @objc func handlePlusPhoto(){
        let imgpickerController = UIImagePickerController()
        imgpickerController.delegate = self
        imgpickerController.allowsEditing = true
        present(imgpickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            plusPhotoBtn.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoBtn.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusPhotoBtn.layer.cornerRadius = plusPhotoBtn.frame.width/2
        plusPhotoBtn.layer.masksToBounds = true
        plusPhotoBtn.layer.borderColor = UIColor.black.cgColor
        plusPhotoBtn.layer.borderWidth = 3
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTextInputChange(){
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        if isFormValid && checkBox.currentTitle! == "1"{
            signUpBtn.isEnabled = true
            signUpBtn.backgroundColor = .mainBlue()
        } else {
            signUpBtn.isEnabled = false
            signUpBtn.backgroundColor = UIColor.rgb(red: 149,green: 204,blue: 244)
        }
    }
    
    @objc func handleSignUp(){
        enableSignupBtn(bool: false)
        
        guard let email = emailTextField.text, email.count > 0 else {return}
        guard let password = passwordTextField.text, password.count > 0 else {return}
        
        // create user
        Auth.auth().createUser(withEmail: email, password: password) { (user: User?, error: Error?) in
            if let _ = error {
                
                showErr(info: NSLocalizedString("failCreateUser", comment: ""), subInfo: NSLocalizedString("checkEmail", comment: ""))
                return
            }
            print("Successfully created user: ", user?.uid ?? "")
            
            user?.sendEmailVerification(completion: { (err) in
                
                if let _ = err {
                    showErr(info: NSLocalizedString("failSendEmail", comment: ""), subInfo: NSLocalizedString("trySignupLater", comment: ""))
                }
                
                let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
                let alert = SCLAlertView(appearance: appearance)
                alert.addButton(NSLocalizedString("verifiedEmail", comment: ""), action: {
                    self.isEmailVerified(user: user)
                })
                
                alert.showSuccess(NSLocalizedString("emailSent", comment: ""), subTitle: NSLocalizedString("verifyEmail", comment: ""))
                
            })
        }
    }
    
    fileprivate func showCheckEmailAlert(user: User){
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton(NSLocalizedString("verifiedEmail", comment: ""), action: {
            self.isEmailVerified(user: user)
        })
        alert.addButton(NSLocalizedString("trylater", comment: "")) {
            user.delete(completion: nil)
            user.delete(completion: { (err) in
                self.enableSignupBtn(bool: true)
            })
        }
        alert.showWarning(NSLocalizedString("notVerified", comment: ""), subTitle: NSLocalizedString("verifyEmail", comment: ""))
    }
    
    fileprivate func isEmailVerified(user: User?) {
        user?.reload(completion: { (_) in
            guard let isEmailVerified = user?.isEmailVerified else {return}
            if isEmailVerified {
                self.storeUserProfile()
            } else {
                guard let user = user else {return}
                self.showCheckEmailAlert(user: user)
            }
        })
    }
    
    fileprivate func setupInputFields(){
        let stackView = UIStackView(arrangedSubviews: [emailTextField,usernameTextField,passwordTextField,signUpBtn])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoBtn.bottomAnchor, paddingTop: 20, bottom: nil, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 40, right: view.rightAnchor, paddingRight: 40, width: 0, height: 200)

        view.addSubview(checkBox)
        view.addSubview(readEULA)
        view.addSubview(EULA)
        checkBox.anchor(top: stackView.bottomAnchor, paddingTop: 16, bottom: nil, paddingBottom: 0, left: stackView.leftAnchor, paddingLeft: 0, right: nil, paddingRight: 0, width: 24, height: 24)
        readEULA.anchor(top: stackView.bottomAnchor, paddingTop: 16, bottom: nil, paddingBottom: 0, left: checkBox.rightAnchor, paddingLeft: 4, right: EULA.leftAnchor, paddingRight: 2, width: 0, height: 25)
        EULA.anchor(top: stackView.bottomAnchor, paddingTop: 16, bottom: nil, paddingBottom: 0, left: readEULA.rightAnchor, paddingLeft: 2, right: nil, paddingRight: 0, width: 0, height: 25)
    }
    
    //____________________________________________________________________________________
    let alreadyHaveAccountBtn: UIButton = {
        let button = UIButton(type: .system)
        // set attributed title
        let alreadyhaveAccount = NSLocalizedString("alreadyHaveAccount", comment: "")
        let attributedTitle = NSMutableAttributedString(string: "\(alreadyhaveAccount) ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSMutableAttributedString(string: NSLocalizedString("login", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    @objc func handleShowLogin(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    //____________________________________________________________________________________
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init UI
        view.backgroundColor = .white
        view.addSubview(plusPhotoBtn)
        plusPhotoBtn.anchor(top: view.topAnchor, paddingTop: 40, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: nil, paddingRight: 0, width: 140, height: 140)
        plusPhotoBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        setupInputFields()
        
        view.addSubview(alreadyHaveAccountBtn)
        alreadyHaveAccountBtn.anchor(top: nil, paddingTop: 0, bottom: view.bottomAnchor, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 0, height: 50)
        
    }
    
    fileprivate func storeUserProfile(){
        // store user image

        guard let image = plusPhotoBtn.imageView?.image else {return}
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("profile_images").child(filename).putData(uploadData, metadata: nil, completion: { (metadata, err) in
            if let _ = err {
                showErr(info: "Failed to upload profile image", subInfo: tryLater)
                return
            }
            guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else {return}
            print("successfully uploaded profile image", profileImageUrl)
            
            // store user info
            guard let user = Auth.auth().currentUser else {return}
            let uid = user.uid
            guard let username = self.usernameTextField.text, username.count > 0 else {return}
            guard let fcmToken = Messaging.messaging().fcmToken else {return}
            
            let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl, "fcmToken": fcmToken]
            let values = [uid: dictionaryValues]
            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to save user info:",err)
                    return
                }
                print("Successfully saved user info into db")
                
                // entire app -> get app -> initialVC
                guard let mainTabBarVC =  UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController else {return}
                // get a reference of main VC and call setupViewControllers function to update the View
                mainTabBarVC.setupViewControllers()
                self.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    fileprivate func enableSignupBtn(bool: Bool){
        let button = self.signUpBtn
        if bool {
            button.backgroundColor = .mainBlue()
            button.isEnabled = true
        } else {
            button.backgroundColor = UIColor.rgb(red: 149,green: 204,blue: 244)
            button.isEnabled = false
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

