//
//  ChatLogView.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 22/8/22.
//

import SwiftUI

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

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ChatLogView(chatUser: Mockdata.sampleChatUser)
        }
    }
}
