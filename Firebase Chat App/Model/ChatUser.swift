//
//  ChatUser.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 21/8/22.
//

import Foundation

struct ChatUser {
    let uid, email, profileImageUrl: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
    
}
