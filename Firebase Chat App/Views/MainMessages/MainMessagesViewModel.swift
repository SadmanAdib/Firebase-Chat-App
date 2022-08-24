//
//  MainMessagesViewModel.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 21/8/22.
//

import Foundation

class MainMessagesViewModel: ObservableObject {

    @Published private var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    @Published var recentMessages: [RecentMessage] = []

    init() {
        fetchCurrentUser()
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchRecentMessages()
    }
    
    func fetchRecentMessages() {
        //recentMessages.removeAll()
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        FirebaseManager.shared.firestore.collection("recent_messages").document(uid).collection("messages").order(by: "timestamp").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
                return
            }
            snapshot?.documentChanges.forEach { change in
                let docId = change.document.documentID
                
                if let index = self.recentMessages.firstIndex(where: { recentMessage in
                    return recentMessage.documentId == docId
                }) {
                    self.recentMessages.remove(at: index)
                }
                self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
            }
        }
    }

     func fetchCurrentUser() {

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }

        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }

            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return

            }
            
            self.chatUser = .init(data: data)
        }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }

}
