import SwiftUI

struct ProfileView: View {
    @StateObject var model: ProfileViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradients.loginBackground, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                contentView.padding(.bottom, 10)
            }
        }
        .errorToast(isShowing: $model.isShowingError, errorText: model.error)
        
        .environmentObject(model)
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            SettingsSectionView()
            StandardButton(disabled: false, text: "Log out", style: .secondary) {
                self.model.logout()
            }
            .padding(.horizontal, 20)
        }
        .padding([.leading, .trailing], 20)
    }
}


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
