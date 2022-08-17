//
//  LoginView.swift
//  Firebase Chat App
//
//  Created by Sadman Adib on 16/8/22.
//

import SwiftUI
import Firebase
import FirebaseStorage

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
}

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    @State var loginStatusMessage = ""
    @State var showImagePicker = false
    @State var image: UIImage?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 3)
                            )
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }
                        .background(Color.blue)
                        .cornerRadius(10)
                        
                    }
                    
                    Text(loginStatusMessage)
                    
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                    ImagePicker(image: $image)
                        .ignoresSafeArea()
                }
    }
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to login user:", err)
                loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            
            loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
        }
    }
    
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            
            loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
            let ref = FirebaseManager.shared.storage.reference(withPath: uid)
            guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
            ref.putData(imageData, metadata: nil) { metadata, err in
                if let err = err {
                    loginStatusMessage = "Failed to push image to Storage: \(err)"
                    return
                }

                ref.downloadURL { url, err in
                    if let err = err {
                        loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                        return
                    }

                    loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                    print(url?.absoluteString ?? "")
                    
                    guard let url = url else { return }
                    storeUserInformation(imageProfileUrl: url)
                }
            }
        }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let userData = ["email": email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users").document(uid).setData(userData) { err in
            if let err = err {
                print(err)
                loginStatusMessage = "\(err)"
                return
            }
            
            print("Stored User Info Successfully!")
        }
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
