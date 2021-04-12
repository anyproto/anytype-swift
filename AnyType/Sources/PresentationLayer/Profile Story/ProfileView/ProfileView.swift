import SwiftUI

struct ProfileView: View {
    @ObservedObject var model: ProfileViewModel
    
    var contentView: some View {
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
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradients.loginBackground, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                self.contentView.padding(.bottom, 10)
            }
        }
        .errorToast(isShowing: $model.isShowingError, errorText: model.error)
        .onAppear {
            self.model.obtainAccountInfo()
        }
    }
}

struct ProfileSectionView: View {
    @ObservedObject var model: ProfileViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            UserIconView(
                image: self.model.accountData.accountAvatar,
                color: self.model.accountData.visibleSelectedColor,
                name: self.model.accountData.visibleAccountName
            )
            .frame(width: 64, height: 64)
            .padding([.top], 20)

            HStack(spacing: 0) {
                Text(self.model.accountData.visibleAccountName)
                    .font(.title)
                Spacer()
                Image("arrowForward")
            }
            .padding([.top], 11)
            .onTapGesture {
                // TODO: go to profile
            }

            HStack(spacing: 6) {
                Text("Your public page")
                    .foregroundColor(ColorPalette.grayText)
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
    @ObservedObject var viewModel: ViewModel = .init()

    var body: some View {
        VStack(spacing: 12) {
            SettingsSectionItemView(name: "Wallpaper", icon: "Settings/wallpaper", pressed: self.$viewModel.wallpaper).modifier(DividerModifier())
            SettingsSectionItemView(name: "Keychain phrase", icon: "Settings/key", pressed: self.$viewModel.keychain).modifier(DividerModifier())
                .sheet(isPresented: self.$viewModel.keychain) {
                    KeychainPhraseView(viewModel: .init(), showKeychainView: self.$viewModel.keychain)
            }
            SettingsSectionItemView(name: "Pin code", icon: "Settings/lock", pressed: self.$viewModel.pincode).modifier(DividerModifier())
            SettingsSectionToggleItemView(name: "Updates", icon: "Settings/updates", switched: self.$viewModel.updates).modifier(DividerModifier())
            SettingsSectionToggleItemView(name: "Invites", icon: "Settings/invites", switched: self.$viewModel.invites).modifier(DividerModifier())
            SettingsSectionItemView(name: "About application", icon: "", pressed: self.$viewModel.about).modifier(DividerModifier())
                .sheet(isPresented: self.$viewModel.about) {
                    ProfileView.AboutView(viewModel: .init())
            }
        }
        .padding([.leading, .trailing], 20)
        .padding([.bottom, .top], 20)
        .background(Color.white)
        .cornerRadius(12.0)
    }
}

// MARK: - SettingsSectionView / ViewModel
extension SettingsSectionView {
    class ViewModel: ObservableObject {
        @Published var wallpaper: Bool = false
        @Published var keychain: Bool = false
        @Published var pincode: Bool = false
        @Published var updates: Bool = false
        @Published var invites: Bool = false
        @Published var about: Bool = false
    }
}

// MARK: - SettingsSectionView / DividerModifier
extension SettingsSectionView {
    struct DividerModifier: ViewModifier {
        func body(content: Content) -> some View {
            VStack {
                content
                Divider().foregroundColor(Color("DividerColor"))
            }
        }
    }
}

// MARK: - SettingsSectionItemView
struct SettingsSectionItemView: View {
    @State var name: String
    @State var icon: String
    @Binding var pressed: Bool

    var body: some View {
        HStack(spacing: 8) {
            if !self.icon.isEmpty {
                Image(icon).frame(width: 24.0, height: 24.0)
            }
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

// MARK: - SettingsSectionToggleItemView
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
//struct ProfileView_Previews : PreviewProvider {
////    private struct ProfileService: ProfileServiceProtocol {
////        var name: String = "Anton Pronkin"
////        var avatar: String = ""
////    }
////    private struct AuthService: AuthServiceProtocol {
////        func login(recoveryPhrase: String, completion: @escaping (Error?) -> Void) {}
////        func logout(completion: @escaping () -> Void) {}
////        func createAccount(profile: AuthModels.CreateAccount.Request, alphaInviteCode: String, onCompletion: @escaping OnCompletion) {}
////        func createWallet(in path: String, onCompletion: @escaping OnCompletionWithEmptyResult) {}
////        func walletRecovery(mnemonic: String, path: String, onCompletion: @escaping OnCompletionWithEmptyResult) {}
////        func accountRecover(onCompletion: @escaping OnCompletionWithEmptyResult) {}
////        func selectAccount(id: String, path: String, onCompletion: @escaping OnCompletion) {}
////    }
////
////    static var previews: some View {
////        let viewModel = ProfileViewModel(profileService: ProfileService(), authService: AuthService())
////        return ProfileView(model: viewModel)
////    }
//}
#endif
