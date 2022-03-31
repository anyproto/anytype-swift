import SwiftUI
import Combine
import ProtobufMessages

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
    
    private var cancellable: AnyCancellable?
    
    private var isAccountSelected = false
    
    func accountRecover() {
        handleAccountShowEvent()
        authService.accountRecover { [weak self] error in
            guard let self = self, let error = error else { return }
            
            self.errorText = error.localizedDescription
            self.snackBarData = .empty
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self, !self.isAccountSelected else { return }
            
            self.snackBarData = .init(text: "Setting up encrypted storage\nPlease wait".localized, showSnackBar: true)
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
        authService.selectAccount(id: id) { [weak self] isSelected in
            guard let self = self else { return }
            self.isAccountSelected = true
            self.snackBarData = .empty
            
            if isSelected {
                WindowManager.shared.showHomeWindow()
            } else {
                self.errorText = "Select account error".localized
            }
        }
    }
}
