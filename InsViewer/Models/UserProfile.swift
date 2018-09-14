//
//  UserProfile.swift
//  InsViewer
//
//  Created by Renrui Liu on 14/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation

//____________________________________________________________________________________
struct UserProfile{
    let username: String
    let profileImgUrl: String
    
    init(dict:[String:Any]){
        // sign the database dictionary to local userProfile dictionary
        self.username = dict["username"] as? String ?? ""
        self.profileImgUrl = dict["profileImageUrl"] as? String ?? ""
    }
}
