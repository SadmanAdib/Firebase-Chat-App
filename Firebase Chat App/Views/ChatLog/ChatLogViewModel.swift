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
    @Published var count = 0
    private var tempChatText = ""
    
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
                
                DispatchQueue.main.async {
                    self.count += 1
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
            
            self.persistRecentMessage()
            //temp variable needed as before completion of the persisRecentMessage() function, the chatText is being set to empty string. Don't know why!
            self.tempChatText = self.chatText
            self.chatText = ""
            self.count += 1
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
    
    private func persistRecentMessage() {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {return}
        guard let toId = chatUser?.uid else {return}
        
        let document = FirebaseManager.shared.firestore.collection("recent_messages").document(fromId).collection("messages").document(toId)
        
        let data = [
            "timestamp": Timestamp(),
            "text": self.chatText,
            "fromId": fromId,
            "toId": toId,
            "profileImageUrl": chatUser?.profileImageUrl ?? "",
            "email": chatUser?.email ?? ""
        ] as [String : Any]
        
        document.setData(data) { err in
            if let err = err {
                print(err)
                return
            }
        }
        
        var currentUserProfileImageUrl = ""
        
        FirebaseManager.shared.firestore.collection("users").document(fromId).getDocument { snapshot, err in
            if let err = err {
                print(err)
            }
            //needed to access the currentUserProfileImageUrl directly as couldn't access via currentUser.profileImageUrl
            currentUserProfileImageUrl = snapshot?["profileImageUrl"] as? String ?? ""
            guard let currentUser = FirebaseManager.shared.auth.currentUser else {return}
            let recipientRecentMessageDictionary = [
                "timestamp": Timestamp(),
                "text": self.tempChatText,
                "fromId": fromId,
                "toId": toId,
                "profileImageUrl": currentUserProfileImageUrl,
                "email": currentUser.email ?? ""
            ] as [String : Any]
            
            FirebaseManager.shared.firestore
                .collection("recent_messages")
                .document(toId)
                .collection("messages")
                .document(currentUser.uid)
                .setData(recipientRecentMessageDictionary) { error in
                    if let error = error {
                        print("Failed to save recipient recent message: \(error)")
                        return
                    }
                }
        }
    }
}
