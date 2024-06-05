import Foundation
import UIKit

@MainActor
final class DashboardLogoutAlertModel: ObservableObject {
    
    
    // MARK: - DI
    
    @Injected(\.authService)
    private var authService: AuthServiceProtocol
    private let onBackup: () -> Void
    private let onLogout: () -> Void
    
    init(
        onBackup: @escaping () -> Void,
        onLogout: @escaping () -> Void
    ) {
        self.onBackup = onBackup
        self.onLogout = onLogout
    }
    
    func onBackupTap() {
        onBackup()
    }
    
    func onLogoutTap() async throws {
        AnytypeAnalytics.instance().logLogout()

        do {
            try await authService.logout(removeData: false)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onLogout()
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            throw error
        }
    }
}
