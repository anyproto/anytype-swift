import SwiftUI

final class SignUpData: ObservableObject {
    @Published var userName: String
    @Published var image: UIImage?
    @Published var inviteCode: String
    var mnemonic: String
    
    init(mnemonic: String) {
        userName = ""
        image = nil
        inviteCode = ""

        self.mnemonic = mnemonic
    }
}

class WaitingOnCreatAccountViewModel: ObservableObject {
    private let authService = ServiceLocator.shared.authService()
    private let loginStateService = ServiceLocator.shared.loginStateService()
    
    private let diskStorage = DiskStorage()
    
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
            
            let result = self.authService.createAccount(
                name: self.signUpData.userName,
                imagePath: self.imagePath(),
                alphaInviteCode: self.signUpData.inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                
                switch result {
                case .failure(let error):
                    self.error = error.localizedDescription
                    self.showError = true
                case .success:
                    self.loginStateService.setupStateAfterRegistration()
                    WindowManager.shared.showHomeWindow()
                }
            }
        }
    }
    
    private func imagePath() -> String {
        guard let image = signUpData.image else { return "" }
        
        let imageName = "avatar_\(self.signUpData.userName.trimmingCharacters(in: .whitespacesAndNewlines))_\(UUID())"
        return diskStorage.saveImage(imageName: imageName, image: image) ?? ""
    }
    
}
