import SwiftUI
import Combine

@MainActor
final class SelectProfileViewModel: ObservableObject {
    
    @Published var showError: Bool = false
    var errorText: String? {
        didSet {
            showError = errorText.isNotNil
        }
    }
    
    @Published var snackBarData = SnackBarData.empty
    
    private let authService = ServiceLocator.shared.authService()
    private let fileService = ServiceLocator.shared.fileService()
    private let accountEventHandler = ServiceLocator.shared.accountEventHandler()
    
    private var cancellable: AnyCancellable?
    
    private var isAccountRecovering = false
    
    let windowManager: WindowManager
    
    init(windowManager: WindowManager) {
        self.windowManager = windowManager
    }
    
    func accountRecover() {
        handleAccountShowEvent()
        
        isAccountRecovering = true
        authService.accountRecover { [weak self] error in
            guard let self = self, let error = error else { return }
            
            self.isAccountRecovering = false
            self.errorText = error.localizedDescription
            self.snackBarData = .empty
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self, self.isAccountRecovering else { return }
            
            self.snackBarData = .init(text: Loc.settingUpEncryptedStoragePleaseWait, showSnackBar: true)
        }
    }
    
}

// MARK: - Private func

private extension SelectProfileViewModel {
    
    func handleAccountShowEvent() {
        cancellable = accountEventHandler.accountShowPublisher
            .sink { [weak self] accountId in
                self?.selectProfile(id: accountId)
            }
    }
    
    func selectProfile(id: String) {
        authService.selectAccount(id: id) { [weak self] status in
            guard let self = self else { return }
            self.isAccountRecovering = false
            self.snackBarData = .empty
            
            switch status {
            case .active:
                self.windowManager.showHomeWindow()
            case .pendingDeletion(let deadline):
                self.windowManager.showDeletedAccountWindow(deadline: deadline)
            case .deleted:
                self.errorText = Loc.accountDeleted
            case .none:
                self.errorText = Loc.selectAccountError
            }
        }
    }
}
