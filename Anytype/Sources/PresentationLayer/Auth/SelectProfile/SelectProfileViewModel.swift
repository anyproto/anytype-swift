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
    
    private let authService = ServiceLocator.shared.authService()
    private let fileService = ServiceLocator.shared.fileService()
    
    private var cancellable: AnyCancellable?
    
    func accountRecover() {
        self.handleAccountShowEvent()
        DispatchQueue.global().async { [weak self] in
            self?.authService.accountRecover()
//            if let error = self?.authService.accountRecover() {
//                DispatchQueue.main.async {
//                    self?.error = error.localizedDescription
//                }
//            }
        }
    }
    
    func selectProfile(id: String) {
        if authService.selectAccount(id: id) {
            showHomeView()
        } else {
            self.errorText = "Select account error".localized
        }
    }
    
    // MARK: - Private func
    
    private func handleAccountShowEvent() {
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
                    
                    if case Anytype_Event.Message.OneOf_Value.accountShow = value {
                        return true
                    }
                    return false
                }
            }
            .filter { $0.count > 0 } 
            .receiveOnMain()
            .sink { [weak self] events in
                guard let self = self else {
                    return
                }
                
                self.selectProfile(id: events[0].accountShow.account.id)
            }
    }
    
    func showHomeView() {
        let homeAssembly = HomeViewAssembly()
        windowHolder?.startNewRootView(homeAssembly.createHomeView())
    }
}
