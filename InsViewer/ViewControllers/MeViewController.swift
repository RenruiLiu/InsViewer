//
//  MeViewController.swift
//  InsViewer
//
//  Created by Renrui Liu on 10/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit
import Firebase

class MeViewController: UIViewController {

    func resetPassword(){
        let userEmail = "renruil@student.unimelb.edu.au"
        Auth.auth().sendPasswordReset(withEmail: userEmail, completion: nil)
    }
    
    func logout(){
        try? Auth.auth().signOut()
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        self.present(loginVC, animated: true)
    }
    
    @IBAction func logoutBtnAction(_ sender: UIButton) {
        logout()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("open me page")
        let user = Auth.auth().currentUser
        if let user = user{
            print(user.uid)
            print(user.email!)
        }
    }

}
