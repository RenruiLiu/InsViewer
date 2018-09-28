//
//  Post.swift
//  InsViewer
//
//  Created by Renrui Liu on 14/9/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import Foundation

struct Post {
    
    var id: String?
    let imageUrl: String
    let user: UserProfile
    let caption: String
    let creationDate: Date
    var hasLiked = false
    var hasSaved = false
    let postImgFileName: String
    
    init(user: UserProfile, dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.user = user
        self.caption = dictionary["caption"] as? String ?? ""
        self.postImgFileName = dictionary["postImgFileName"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
