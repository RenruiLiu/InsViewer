//
//  Comment.swift
//  InsViewer
//
//  Created by Renrui Liu on 17/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation

struct Comment {
    let user: UserProfile
    let text: String
    let uid: String
    
    init(user: UserProfile, dictionary:[String:Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
