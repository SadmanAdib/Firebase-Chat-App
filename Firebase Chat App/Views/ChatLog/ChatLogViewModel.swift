//
//  ChatLogViewModel.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 23/8/22.
//

import SwiftUI
import Firebase

class ChatLogViewModel: ObservableObject {
    @Published var chatText = ""
    private var chatUser: ChatUser?
    @Published var chatMessages: [ChatMessage] = []
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    private func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {return}
        guard let toId = chatUser?.uid else {return}
        
        FirebaseManager.shared.firestore.collection("messages").document(fromId).collection(toId).order(by: "timestamp")
            .addSnapshotListener { snapshot, err in
                if let err = err {
                    print(err)
                    return
                }
                snapshot?.documentChanges.forEach{ change in
                    if change.type == .added {
                        let data = change.document.data()
//                        let chatMessage = ChatMessage(fromId: data["fromId"] as! String, toId: data["toId"] as! String, text: data["text"] as! String)
                        let chatMessage = ChatMessage(data: data, documentId: change.document.documentID)
                        self.chatMessages.append(chatMessage)
                    }
                }
            }
    }
    
    func handleSend() {
        //print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {return}
        guard let toId = chatUser?.uid else {return}
        
        let senderMessageDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = ["fromId": fromId, "toId": toId, "text": chatText, "timestamp": Timestamp()] as [String : Any]
        
        senderMessageDocument.setData(messageData) { err in
            if let err = err {
                print(err)
                return
            }
            
            print("Successfully saved message from sender end")
            self.chatText = ""
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { err in
            if let err = err {
                print(err)
                return
            }
            
            print("Successfully saved message from reciever end")
        }
    }
}
