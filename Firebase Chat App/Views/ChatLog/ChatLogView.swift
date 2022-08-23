//
//  ChatLogView.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 22/8/22.
//

import SwiftUI
import Firebase

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

struct ChatLogView: View {
    
    @StateObject var vm: ChatLogViewModel
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self._vm = StateObject(wrappedValue: ChatLogViewModel(chatUser: chatUser))
        //self.vm = .init(chatUser: chatUser)
    }
    
    var chatUser: ChatUser?
    
    var body: some View {
        ZStack {
            chatMessagesView
            VStack(spacing: 0) {
                Spacer()
                chatBottomBar
                    .background(Color.white.ignoresSafeArea())
            }
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                vm.handleSend()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var chatMessagesView: some View {
        ScrollView {
            ForEach(vm.chatMessages) { message in
                VStack{
                    if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                        HStack {
                            Spacer()
                            HStack {
                                Text(message.text)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                    }
                    else {
                        HStack {
                            HStack {
                                Text(message.text)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            HStack{ Spacer() }
                .frame(height: 50)
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

//struct ChatLogView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView{
//            ChatLogView()
//        }
//    }
//}
