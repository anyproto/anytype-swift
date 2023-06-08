import Foundation
import Combine
import UIKit

@MainActor
final class DashboardAccountDeletionAlertModel: ObservableObject {
    
    // MARK: - DI
    
    private let authService: AuthServiceProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    
    init(
        authService: AuthServiceProtocol,
        applicationStateService: ApplicationStateServiceProtocol
    ) {
        self.authService = authService
        self.applicationStateService = applicationStateService
    }
    
    func accountDeletionConfirm() {
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.deleteAccount)
        guard let status = authService.deleteAccount() else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        switch status {
        case .active:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        case .pendingDeletion:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            applicationStateService.state = .delete
        case .deleted:
            logout()
            break
        }
    }
    
    private func logout() {
        
        AnytypeAnalytics.instance().logEvent(
            AnalyticsEventsName.logout,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.route: AnalyticsEventsName.settingsShow
            ]
        )

        authService.logout(removeData: true) { [weak self] isSuccess in
            guard isSuccess else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self?.applicationStateService.state = .auth
        }
    }
}
