//
//  MainMessagesView.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 17/8/22.
//

import SwiftUI
import Firebase

struct RecentMessage: Identifiable {

    var id: String { documentId }

    let documentId: String
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Timestamp

    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @StateObject var vm = MainMessagesViewModel()
    @State private var showNewMessageView = false
    @State private var showChatLogView = false
    @State private var chatUser: ChatUser?

        var body: some View {
            NavigationView {

                VStack {
                    CustomNavBar(vm: vm, shouldShowLogOutOptions: $shouldShowLogOutOptions)
                    MessagesView(vm: vm)
                    
                    NavigationLink("", isActive: $showChatLogView) {
                        ChatLogView(chatUser: chatUser)
                    }
                }
                .overlay(
                    newMessageButton, alignment: .bottom)
                .navigationBarHidden(true)
            }
        }

        private var newMessageButton: some View {
            Button {
                showNewMessageView.toggle()
            } label: {
                HStack {
                    Spacer()
                    Text("+ New Message")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical)
                    .background(Color.blue)
                    .cornerRadius(32)
                    .padding(.horizontal)
                    .shadow(radius: 15)
            }
            .fullScreenCover(isPresented: $showNewMessageView) {
                NewMessageView(selectedChatUser: { user in
                    //print(user.email)
                    chatUser = user
                    showNewMessageView.toggle()
                    showChatLogView.toggle()
                })
            }
        }
}

struct CustomNavBar: View {
    
    @ObservedObject var vm: MainMessagesViewModel
    @Binding var shouldShowLogOutOptions: Bool
    
    var body: some View{
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: vm.chatUser?.profileImageUrl ?? "")) { returnedImage in
                returnedImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                        .stroke(Color(.label), lineWidth: 1)
                    )
                    .shadow(radius: 5)
            } placeholder: {
                ProgressView()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? "")
                    .font(.system(size: 24, weight: .bold))

                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }

            }

            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
            LoginView(didCompleteLoginProcess: {
                vm.isUserCurrentlyLoggedOut = false
                vm.fetchCurrentUser()
                vm.fetchRecentMessages()
                vm.recentMessages.removeAll()
            })
        }
    }
}

struct MessagesView: View {
    @ObservedObject var vm: MainMessagesViewModel
    var body: some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    HStack(spacing: 16) {
                        AsyncImage(url: URL(string: recentMessage.profileImageUrl)) { returnedImage in
                            returnedImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(60)
                                .overlay(RoundedRectangle(cornerRadius: 60)
                                    .stroke(Color(.label), lineWidth: 1)
                                )
                                .shadow(radius: 5)
                        } placeholder: {
                            ProgressView()
                        }
                        VStack(alignment: .leading) {
                            Text(recentMessage.email)
                                .font(.system(size: 16, weight: .bold))
                            Text(recentMessage.text)
                                .font(.system(size: 14))
                                .foregroundColor(Color(.lightGray))
                        }
                        Spacer()

                        Text("22d")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)

            }.padding(.bottom, 50)
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
