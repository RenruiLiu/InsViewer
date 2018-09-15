//
//  Post.swift
//  InsViewer
//
//  Created by Renrui Liu on 14/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation

struct Post {
    let imageUrl: String
    let user: UserProfile
    let caption: String
    let creationData: Date
    
    init(user: UserProfile, dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.user = user
        self.caption = dictionary["caption"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationData = Date(timeIntervalSince1970: secondsFrom1970)
    }
}