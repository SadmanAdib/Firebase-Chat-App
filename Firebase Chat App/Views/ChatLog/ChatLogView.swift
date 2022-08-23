//
//  ChatLogView.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 22/8/22.
//

import SwiftUI
import Firebase

class ChatLogViewModel: ObservableObject {
    @Published var chatText = ""
    private var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
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
            ChatMessagesView()
            VStack(spacing: 0) {
                Spacer()
                ChatBottomBar
                    .background(Color.white.ignoresSafeArea())
            }
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var ChatBottomBar: some View {
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
}


private struct ChatMessagesView: View {
    var body: some View {
        ScrollView {
            ForEach(0..<20) { num in
                HStack {
                    Spacer()
                    HStack {
                        Text("FAKE MESSAGE FOR NOW")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
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
