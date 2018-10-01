//
//  Comment.swift
//  InsViewer
//
//  Created by Renrui Liu on 17/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation

struct Comment {
    var id : String?
    let user: UserProfile
    let text: String
    let uid: String
    var postId: String?
    let creationDate: Date

    init(user: UserProfile, dictionary:[String:Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
