import Combine
import UIKit

final class DeletedAccountViewModel: ObservableObject {
    
    private let service = ServiceLocator.shared.authService()
    
    let progress: DeletionProgress
    
    // MARK: - Initializer
    
    init(progress: DeletionProgress) {
        self.progress = progress
    }
    
    // MARK: - Internal var
    
    var deletionProgress: CGFloat {
        let daysToDeletion = CGFloat(progress.daysToDeletion)
        let maxDaysDeadline = CGFloat(DeletionProgress.Constants.maxDaysDeadline)
        let progress: CGFloat = (daysToDeletion / maxDaysDeadline).clamped(0.1, 0.9)
        return 1.0 - progress
    }
    
    var title: String {
        let dayText: String
        if progress.daysToDeletion == 0 {
            dayText = "today".localized
        } else if progress.daysToDeletion == 1 {
            dayText = "tomorrow".localized
        } else {
            dayText = "\("in".localized) \(progress.daysToDeletion) \("days".localized)"
        }
        
        let localizedPrefix = "This account will be deleted".localized
        return "\(localizedPrefix) \(dayText)"
    }
    
    // MARK: - Internal funcs
    
    func logOut() {
        service.logout(removeData: true) { isSuccess in
            guard isSuccess else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            WindowManager.shared.showAuthWindow()
        }
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
