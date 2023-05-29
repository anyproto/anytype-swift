import Foundation
import UIKit

@MainActor
final class DashboardLogoutAlertModel: ObservableObject {
    
    @Published var isLogoutInProgress = false
    
    // MARK: - DI
    
    private let authService: AuthServiceProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    private let onBackup: () -> Void
    
    init(
        authService: AuthServiceProtocol,
        applicationStateService: ApplicationStateServiceProtocol,
        onBackup: @escaping () -> Void
    ) {
        self.authService = authService
        self.applicationStateService = applicationStateService
        self.onBackup = onBackup
    }
    
    func onBackupTap() {
        onBackup()
    }
    
    func onLogoutTap() {
        isLogoutInProgress = true
        AnytypeAnalytics.instance().logEvent(
            AnalyticsEventsName.logout,
            withEventProperties: [
                AnalyticsEventsPropertiesKey.route: AnalyticsEventsName.settingsShow
            ]
        )

        authService.logout(removeData: false) { [weak self] isSuccess in
            guard isSuccess else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self?.applicationStateService.state = .auth
        }
    }
}
