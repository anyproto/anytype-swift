import Combine
import UIKit

final class DeletedAccountViewModel: ObservableObject {
    private let service = ServiceLocator.shared.authService()
    
    func logOut() {
        guard service.logout(removeData: true) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
    }
    
    func cancel() {
        guard let status = service.restoreAccount() else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        if case .active = status {
            windowHolder?.startNewRootView(HomeViewAssembly().createHomeView())
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
    }
}
