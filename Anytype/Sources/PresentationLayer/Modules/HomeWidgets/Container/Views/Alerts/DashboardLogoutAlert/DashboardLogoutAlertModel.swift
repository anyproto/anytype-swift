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

        Task {
            do {
                try await authService.logout(removeData: false)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onLogout()
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}
