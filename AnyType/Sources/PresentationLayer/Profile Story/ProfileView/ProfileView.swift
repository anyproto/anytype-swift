//
//  ProfileView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 12.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct ProfileView : View {
    private let defautlNavColor = UINavigationBar.appearance().barTintColor
    private let defautlNavShadow = UINavigationBar.appearance().shadowImage
       
    @ObservedObject var model: ProfileViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack {
                    if model.accountAvatar != nil {
                        Image(uiImage: model.accountAvatar!)
                    } else {
                        Text(String(model.accountName.first ?? "A"))
                            .padding(.all, 30)
                            .font(.title)
                            .background(Color(model.selectedColor))
                            .foregroundColor(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white))
                    }
                    Text("\(model.accountName)")
                }
                .padding()
                
                Form {
                    NavigationLink(destination: ProfileSettingsView(accountImage: $model.accountAvatar, accountName: $model.accountName, selectedColor: $model.selectedColor)) {
                        Text("Profile settings")
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                            .padding([.top, .bottom])
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Notifications")
                        Toggle(isOn: $model.updates) {
                            Text("Updates")
                        }
                        Toggle(isOn: $model.newInvites) {
                            Text("New invites")
                        }
                        Toggle(isOn: $model.newComments) {
                            Text("New comments")
                        }
                        Toggle(isOn: $model.newDevice) {
                            Text("New device paired")
                        }
                    }.padding(.top)
                    
                    NavigationLink(destination: Text("1")) {
                        Text("Pin code")
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                            .padding([.top, .bottom])
                    }
                    
                    NavigationLink(destination: Text("123")) {
                        Text("Keychain phrase")
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                            .padding([.top, .bottom])
                    }
                    
                    NavigationLink(destination: Text("123")) {
                        Text("About")
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                            .padding([.top, .bottom])
                    }
                }
                
                HStack {
                    StandardButton(disabled: .constant(false), text: "Log out", style: .white) {
                        self.model.logout()
                    }
                    .offset(y: -40)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .background(Color("backgroundColor"))
            .navigationBarTitle("", displayMode: .inline)
        }
        .errorToast(isShowing: $model.isShowingError, errorText: $model.error)
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
    }
    
    private func onAppear() {
        UINavigationBar.appearance().barTintColor = UIColor(named: "backgroundColor")
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    private func onDisappear() {
        UINavigationBar.appearance().barTintColor = defautlNavColor
        UINavigationBar.appearance().shadowImage = defautlNavShadow
    }
}

#if DEBUG
struct ProfileView_Previews : PreviewProvider {
    private struct ProfileService: ProfileServiceProtocol {
        var name: String = "Anton Pronkin"
        var avatar: String = ""
    }
//    private struct AuthService: AuthServiceProtocol {
//        func login(seed: String, completion: @escaping (Error?) -> Void) {
//        }
//        
//        func login(recoveryPhrase: String, completion: @escaping (Error?) -> Void) {
//        }
//        
//        func logout(completion: @escaping () -> Void) {
//        }
//        
//        func createWalletAndAccount(onReceivingRecoveryPhrase: @escaping OnReceivingRecoveryPhrase) {
//        }
//        
//        func generateRecoveryPhrase(wordCount: Int?) throws -> String {
//            return ""
//        }
//        
//        func createWalletAndAccount(with recoveryPhrase: String, onReceivingRecoveryPhrase: @escaping OnReceivingRecoveryPhrase) {
//        }
//    }
//    
    static var previews: some View {
//        let viewModel = ProfileViewModel(profileService: ProfileService(), authService: AuthService())
        return Text("")
    }
}
#endif
