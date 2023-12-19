import Foundation
import UIKit

@MainActor
final class DashboardLogoutAlertModel: ObservableObject {
    
    @Published var isLogoutInProgress = false
    
    // MARK: - DI
    
    private let authService: AuthServiceProtocol
    private let onBackup: () -> Void
    private let onLogout: () -> Void
    
    init(
        authService: AuthServiceProtocol,
        onBackup: @escaping () -> Void,
        onLogout: @escaping () -> Void
    ) {
        self.authService = authService
        self.onBackup = onBackup
        self.onLogout = onLogout
    }
    
    func onBackupTap() {
        onBackup()
    }
    
    func onLogoutTap() {
        isLogoutInProgress = true
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.logout)

        authService.logout(removeData: false) { [weak self] isSuccess in
            guard let self, isSuccess else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onLogout()
        }
    }
}
