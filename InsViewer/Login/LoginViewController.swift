//
//  LoginViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 12/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    let logoContainerView: UIView = {
        let view = UIView()
        let logoImgView = UIImageView(image: #imageLiteral(resourceName: "picture2-2-"))
        logoImgView.contentMode = .scaleAspectFit
        view.addSubview(logoImgView)
        logoImgView.anchor(top: nil, paddingTop: 0, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: nil, paddingRight: 0, width: 200, height: 50)
        logoImgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImgView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        let email = NSLocalizedString("email", comment: "")
        tf.placeholder = email
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    let passwordTextField: UITextField = {
        let tf = UITextField()
        let password = NSLocalizedString("password", comment: "")
        tf.placeholder = password
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    let loginBtn: UIButton = {
        let button = UIButton(type: .system)
        let login = NSLocalizedString("login", comment: "")
        button.setTitle(login, for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149,green: 204,blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    fileprivate func setupInputFields(){
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginBtn])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, paddingTop: 40, bottom: nil, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 40, right: view.rightAnchor, paddingRight: 40, width: 0, height: 140)
    }
    
    @objc func handleTextInputChange(){
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        if isFormValid {
            loginBtn.isEnabled = true
            loginBtn.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            loginBtn.isEnabled = false
            loginBtn.backgroundColor = UIColor.rgb(red: 149,green: 204,blue: 244)
        }
    }
    
    // login
    @objc func handleLogin(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if let _ = err {
                let failLogin = NSLocalizedString("failLogin", comment: "")
                let checkEmailPwd = NSLocalizedString("checkEmailPwd", comment: "")
                showErr(info: failLogin, subInfo: checkEmailPwd)
                return
            }
            print("Login Successfully with user: ", user?.uid ?? "")
            
            // store user info
            guard let user = Auth.auth().currentUser else {return}
            let uid = user.uid
            guard let fcmToken = Messaging.messaging().fcmToken else {return}
            
            let values = ["fcmToken": fcmToken]
            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to save user info into db: ", err)
                    return
                }
                print("Successfully saved user info into db")
                
                // entire app -> get app -> initialVC
                guard let mainTabBarVC =  UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController else {return}
                // get a reference of main VC and call setupViewControllers function to update the View
                mainTabBarVC.setupViewControllers()
                self.dismiss(animated: true, completion: nil)
            })
        }
    }

    //____________________________________________________________________________________
    let DontHaveAccountBtn: UIButton = {
        let button = UIButton(type: .system)
        // set attributed title
        let donthaveAccount = NSLocalizedString("donthaveAccount", comment: "")
        let signUp = NSLocalizedString("signUp", comment: "")
        
        let attributedTitle = NSMutableAttributedString(string: "\(donthaveAccount) ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSMutableAttributedString(string: signUp, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    @objc func handleShowSignUp(){

        let signUpVC = SignUpViewController()
        
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //____________________________________________________________________________________
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 0, height: 150)
        
        setupInputFields()
        
        view.addSubview(DontHaveAccountBtn)
        DontHaveAccountBtn.anchor(top: nil, paddingTop: 0, bottom: view.bottomAnchor, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 0, height: 50)
        
    }

}
