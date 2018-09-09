//
//  LoginViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 9/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    //
    @IBOutlet weak var usenameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //functions
    
    func signup(){
        Auth.auth().createUser(withEmail: usenameTextField.text!, password: passwordTextField.text!, completion: {(user,error) in
            if error != nil {
                // This should display error message to the user
                print(error!)
            } else {
                print("signup!")
                let rootVC = RootViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
                self.present(rootVC, animated: true, completion: nil)
            }
        })
    }
    
    func login(){
        
    }
    
    func setupUserProfile(){
        
    }
    
    @IBAction func signupBtnAction(_ sender: UIButton) {
        print("sign button pressed")
        signup()
        
    }
    @IBAction func loginBtnAction(_ sender: UIButton) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("say something")
    }
}
