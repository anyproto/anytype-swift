import Foundation
import Combine
import UIKit

@MainActor
final class DashboardAccountDeletionAlertModel: ObservableObject {
    
    // MARK: - DI
    @Injected(\.authService)
    private var authService: any AuthServiceProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol
    
    @Published var toastBarData: ToastBarData?
    
    func accountDeletionConfirm() async {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AnytypeAnalytics.instance().logDeleteAccount()
        
        do {
            let status = try await authService.deleteAccount()
            
            switch status {
            case .active:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .pendingDeletion:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                applicationStateService.state = .delete
            case .deleted:
                try await logout()
            }
        } catch {
            toastBarData = ToastBarData(error.localizedDescription, type: .failure)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    private func logout() async throws {
        
        AnytypeAnalytics.instance().logLogout()

        do {
            try await authService.logout(removeData: true)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            applicationStateService.state = .auth
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
