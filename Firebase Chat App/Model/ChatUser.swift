//
//  ChatUser.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 21/8/22.
//

import Foundation

struct ChatUser: Identifiable {
    
    var id: String { uid }
    
    let uid, email, profileImageUrl: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}

struct Mockdata {
    static let sampleChatUser = ChatUser(data: ["uid": "123", "email": "sampleEmail@gmail.com", "profileImageUrl": "sampleUrl"])
}

