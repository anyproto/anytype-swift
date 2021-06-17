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
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            self.authService.createAccount(profile: self.buildRequest(), alphaInviteCode: self.signUpData.inviteCode) { result in
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
    
    private func buildRequest() -> CreateAccountRequest {
        let imagePath = signUpData.image.flatMap {
            diskStorage.saveImage(imageName: "avatar_\(signUpData.userName)_\(UUID())", image: $0)
        }
        
        let avatar = ProfileModel.Avatar.imagePath(imagePath ?? "")
                
        return  CreateAccountRequest(name: signUpData.userName, avatar: avatar)
    }
    
    private func obtainCompletionView() -> some View {
        let completionView = CompletionAuthViewCoordinator()
        return completionView.start()
    }
}
