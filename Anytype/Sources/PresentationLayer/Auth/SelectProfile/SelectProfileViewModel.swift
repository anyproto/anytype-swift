import SwiftUI
import Combine
import ProtobufMessages

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
    private let accountEventHandler = ServiceLocator.shared.accountManager()
    
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
        cancellable = NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
            .compactMap { $0.object as? EventsBunch }
            .map(\.middlewareEvents)
            .map {
                $0.filter { message in
                    guard let value = message.value else { return false }
                    guard case Anytype_Event.Message.OneOf_Value.accountShow = value else {
                        return false
                    }
                    
                    return true
                }
            }
            .filter { $0.count > 0 }
            .receiveOnMain()
            .sink { [weak self] events in
                guard
                    let self = self,
                    let event = events.first
                else { return }
                
                self.selectProfile(id: event.accountShow.account.id)
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
