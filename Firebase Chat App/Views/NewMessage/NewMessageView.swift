//
//  NewMessageView.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 21/8/22.
//

import SwiftUI

struct NewMessageView: View {
    @Environment(\.presentationMode) var presentationMode

        @StateObject var vm = NewMessageViewModel()

        var body: some View {
            NavigationView {
                ScrollView {
                    Text(vm.statusMessage)

                    ForEach(vm.users) { user in
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack(spacing: 16) {
                                AsyncImage(url: URL(string: user.profileImageUrl)) { returnedImage in
                                    returnedImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipped()
                                        .cornerRadius(50)
                                        .overlay(RoundedRectangle(cornerRadius: 50)
                                                    .stroke(Color(.label), lineWidth: 2)
                                        )
                                } placeholder: {
                                    ProgressView()
                                }
                                Text(user.email)
                                    .foregroundColor(Color(.label))
                                Spacer()
                            }.padding(.horizontal)
                        }
                        Divider()
                            .padding(.vertical, 8)
                    }
                }.navigationTitle("New Message")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
            }
        }
}

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageView()
    }
}
