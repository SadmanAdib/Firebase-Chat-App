//
//  NewMessageViewModel.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 21/8/22.
//

import Foundation

class NewMessageViewModel: ObservableObject {

    @Published var users = [ChatUser]()
    @Published var statusMessage = ""

    init() {
        fetchAllUsersButCurrent()
    }

    private func fetchAllUsersButCurrent() {
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.statusMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }

                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    //If it is the current user, then do not append to the sending list
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(.init(data: data))
                    }

                })
            }
    }
}
