import Combine
import UIKit

final class DeletedAccountViewModel: ObservableObject {
    private let service = ServiceLocator.shared.authService()
    
    func logOut() {
        guard service.logout(removeData: true) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        WindowManager.shared.showAuthWindow()
    }
    
    func cancel() {
        guard let status = service.restoreAccount() else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        if case .active = status {
            WindowManager.shared.showHomeWindow()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
    }
}
