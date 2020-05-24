//
//  ProfileView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 12.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var model: ProfileViewModel
    
    var body: some View {
        NavigationView {
        ZStack {
            LinearGradient(gradient: Gradients.LoginBackground.gradient, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                ProfileSectionView(model: model)
                SettingsSectionView()
                StandardButton(disabled: false, text: "Log out", style: .white) {
                    self.model.logout()
                }
                .padding(.horizontal, 20)
            }
            .padding([.leading, .trailing], 20)
        }
        .navigationBarHidden(false)
        .navigationBarTitle("", displayMode: .inline)
        .errorToast(isShowing: $model.isShowingError, errorText: model.error)
        }.navigationBarHidden(false)
    }
}

struct ProfileSectionView: View {
    @ObservedObject var model: ProfileViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                if model.accountAvatar != nil {
                    Image(uiImage: model.accountAvatar!)
                } else {
                    UserIconView(color: model.selectedColor, name: String(model.theAccountName.first ?? "A"))
                }
            }
            .frame(width: 64, height: 64)
            .padding([.top], 20)

            HStack(spacing: 0) {
                Text("\(model.theAccountName)")
                    .font(.title)
                Spacer()
                Image("arrowForward")
            }
            .padding([.top], 11)
            .onTapGesture {
                // TODO: go to profile
            }

            HStack(spacing: 6) {
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(Color.green)
                Text("Synced with 32 peers")
            }
            .padding([.top], 1)

            Divider()
                .padding([.top], 14)
                .foregroundColor(Color("DividerColor"))

            HStack(spacing: 0) {
                Spacer()
                Text("Switch profile")
                    .bold()
                    .foregroundColor(Color("GrayText"))
                Spacer()
            }
            .padding([.top], 8)
        }
        .padding([.leading, .trailing], 20)
        .padding(.bottom, 9)
        .background(Color.white)
        .cornerRadius(12.0)
    }
}

struct SettingsSectionView: View {
    @State var wallpaper: Bool = false
    @State var keychain: Bool = false
    @State var pincode: Bool = false
    @State var updates: Bool = false
    @State var invites: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            SettingsSectionItemView(name: "Wallpaper", icon: "settings/wallpaper", pressed: $wallpaper)
            Divider().foregroundColor(Color("DividerColor"))
            SettingsSectionItemView(name: "Keychain phrase", icon: "settings/key", pressed: $keychain)
                .sheet(isPresented: $keychain) {
                    KeychainPhraseView(viewModel: KeychainPhraseViewModel(), showKeychainView: self.$keychain)
            }
            Divider().foregroundColor(Color("DividerColor"))
            SettingsSectionItemView(name: "Pin code", icon: "settings/lock", pressed: $pincode)
            Divider().foregroundColor(Color("DividerColor"))
            SettingsSectionToggleItemView(name: "Updatess", icon: "settings/updates", switched: $updates)
            Divider().foregroundColor(Color("DividerColor"))
            SettingsSectionToggleItemView(name: "Invites", icon: "settings/invites", switched: $invites)
            Divider().foregroundColor(Color("DividerColor"))
        }
        .padding([.leading, .trailing], 20)
        .padding([.bottom, .top], 20)
        .background(Color.white)
        .cornerRadius(12.0)
    }
}

struct SettingsSectionItemView: View {
    @State var name: String
    @State var icon: String
    @Binding var pressed: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(icon)
                .frame(width: 24.0, height: 24.0)
            Text(name)
                .bold()
            Spacer()
            Image("arrowForward")
        }
        // Workaround https://www.hackingwithswift.com/quick-start/swiftui/how-to-control-the-tappable-area-of-a-view-using-contentshape
        .contentShape(Rectangle())
        .onTapGesture {
            self.pressed = true
        }
    }
}

struct SettingsSectionToggleItemView: View {
    @State var name: String
    @State var icon: String
    @Binding var switched: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(icon)
                .frame(width: 24, height: 24)
            Text(name)
                .bold()
            Spacer()
            Toggle(isOn: $switched) {
                Text("")
            }
        }
    }
}

#if DEBUG
struct ProfileView_Previews : PreviewProvider {
    private struct ProfileService: ProfileServiceProtocol {
        var name: String = "Anton Pronkin"
        var avatar: String = ""
    }
    private struct AuthService: AuthServiceProtocol {
        func login(recoveryPhrase: String, completion: @escaping (Error?) -> Void) {}
        func logout(completion: @escaping () -> Void) {}
        func createAccount(profile: AuthModels.CreateAccount.Request, alphaInviteCode: String, onCompletion: @escaping OnCompletion) {}
        func createWallet(in path: String, onCompletion: @escaping OnCompletionWithEmptyResult) {}
        func walletRecovery(mnemonic: String, path: String, onCompletion: @escaping OnCompletionWithEmptyResult) {}
        func accountRecover(onCompletion: @escaping OnCompletionWithEmptyResult) {}
        func selectAccount(id: String, path: String, onCompletion: @escaping OnCompletion) {}
    }

    static var previews: some View {
        let viewModel = ProfileViewModel(profileService: ProfileService(), authService: AuthService())
        return ProfileView(model: viewModel)
    }
}
#endif
