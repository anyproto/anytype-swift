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

class WaitingOnCreatAccountViewModel: ObservableObject {
    private let authService = ServiceLocator.shared.authService()
    private let loginStateService = ServiceLocator.shared.loginStateService()
    private let homeViewAssembly = HomeViewAssembly()
    
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
                    windowHolder?.startNewRootView(self.homeViewAssembly.createHomeView())
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
