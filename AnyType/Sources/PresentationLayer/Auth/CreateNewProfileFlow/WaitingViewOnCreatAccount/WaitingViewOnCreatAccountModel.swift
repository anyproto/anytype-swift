import SwiftUI

final class SignUpData: ObservableObject {
    @Published var userName: String
    @Published var image: UIImage?
    @Published var inviteCode: String
    
    init() {
        userName = ""
        image = nil
        inviteCode = ""
    }
}

class WaitingViewOnCreatAccountModel: ObservableObject {
    private let storeService = ServiceLocator.shared.keychainStoreService()
    private let authService = ServiceLocator.shared.authService()
    
    private var diskStorage = DiskStorage()
    
    private let signUpData: SignUpData
    
    @Published var error: String = ""
    @Published var showError: Bool = false
    
    @Binding var showWaitingView: Bool
    
    init(signUpData: SignUpData, showWaitingView: Binding<Bool>) {
        self.signUpData = signUpData
        self._showWaitingView = showWaitingView
    }
    
    func createAccount() {
        var avatar = ProfileModel.Avatar.color(UIColor.randomColor().toHexString())
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if let image = self.signUpData.image,
               let path = self.diskStorage.saveImage(imageName: "avatar_\(self.signUpData.userName)_\(UUID())", image: image) {
                avatar = ProfileModel.Avatar.imagePath(path)
            }
            let request = AuthModels.CreateAccount.Request(name: self.signUpData.userName, avatar: avatar)
            
            self.authService.createAccount(profile: request, alphaInviteCode: self.signUpData.inviteCode) { result in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    switch result {
                    case .failure(_):
                        self.error = "Sign up error"
                        self.showError = true
                    case .success:
                        windowHolder?.startNewRootView(self.obtainCompletionView())
                    }
                }
            }
        }
    }
    
    private func obtainCompletionView() -> some View {
        let completionView = CompletionAuthViewCoordinator()
        return completionView.start()
    }
}
