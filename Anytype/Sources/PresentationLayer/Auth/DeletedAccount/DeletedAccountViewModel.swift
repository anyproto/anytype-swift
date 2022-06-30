import Combine
import UIKit

final class DeletedAccountViewModel: ObservableObject {
    
    private let service = ServiceLocator.shared.authService()
    private let deadline: Date
    
    // MARK: - Initializer
    
    init(deadline: Date) {
        self.deadline = deadline
    }
    
    // MARK: - Internal var
    
    var deletionProgress: CGFloat {
        let daysToDeletion = CGFloat(daysToDeletion)
        let maxDaysDeadline = CGFloat(Constants.maxDaysDeadline)
        let progress: CGFloat = (daysToDeletion / maxDaysDeadline).clamped(0.1, 0.9)
        return 1.0 - progress
    }
    
    var title: String {
        let dayText: String
        if daysToDeletion == 0 {
            dayText = "today".localized
        } else if daysToDeletion == 1 {
            dayText = "tomorrow".localized
        } else {
            dayText = "\("in".localized) \(daysToDeletion) \("days".localized)"
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
    
    // MARK: - Private vars
    
    private var daysToDeletion: Int {
        Calendar.current
            .numberOfDaysBetween(Date(), and: deadline)
            .clamped(0, Constants.maxDaysDeadline)
    }
}

// MARK: - Constants

private extension DeletedAccountViewModel {
    
    enum Constants {
        static let maxDaysDeadline: Int = 30
    }
    
}
