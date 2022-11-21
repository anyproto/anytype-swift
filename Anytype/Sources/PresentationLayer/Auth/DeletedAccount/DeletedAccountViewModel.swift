import Combine
import UIKit

@MainActor
final class DeletedAccountViewModel: ObservableObject {
    
    private let service = ServiceLocator.shared.authService()
    private let deadline: Date
    private let windowManager: WindowManager
    
    // MARK: - Initializer
    
    init(deadline: Date, windowManager: WindowManager) {
        self.deadline = deadline
        self.windowManager = windowManager
    }
    
    // MARK: - Internal var
    
    var deletionProgress: CGFloat {
        let daysToDeletion = CGFloat(daysToDeletion)
        let maxDaysDeadline = CGFloat(Constants.maxDaysDeadline)
        let progress: CGFloat = (daysToDeletion / maxDaysDeadline).clamped(0.1, 0.9)
        return 1.0 - progress
    }
    
    var title: String {
        return Loc.daysToDeletionAccount(daysToDeletion)
    }
    
    // MARK: - Internal funcs
    
    func logOut() {
        AnytypeAnalytics.instance().logEvent(
            AnalyticsEventsName.logout,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.route: AnalyticsEventsName.screenDeletion
            ]
        )

        service.logout(removeData: true) { [weak self] isSuccess in
            guard isSuccess else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            self?.windowManager.showAuthWindow()
        }
    }
    
    func cancel() {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.cancelDeletion)
        guard let status = service.restoreAccount() else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        if case .active = status {
            windowManager.showHomeWindow()
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
