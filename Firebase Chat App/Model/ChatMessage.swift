//
//  ChatMessage.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 23/8/22.
//

import Foundation

struct ChatMessage: Identifiable {
    var id: String {documentId}
    
    let fromId, toId, text: String
    
    let documentId: String
    
    init(data: [String:Any], documentId: String){
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.documentId = documentId
    }
}
