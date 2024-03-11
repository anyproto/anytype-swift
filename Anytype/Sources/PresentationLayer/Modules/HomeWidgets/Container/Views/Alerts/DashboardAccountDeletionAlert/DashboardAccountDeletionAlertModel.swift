import Foundation
import Combine
import UIKit

@MainActor
final class DashboardAccountDeletionAlertModel: ObservableObject {
    
    // MARK: - DI
    
    private let authService: AuthServiceProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    
    @Published var toastBarData: ToastBarData = .empty
    
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
        
        Task {
            do {
                let status = try await authService.deleteAccount()
                
                switch status {
                case .active:
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                case .pendingDeletion:
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    applicationStateService.state = .delete
                case .deleted:
                    logout()
                }
            } catch {
                toastBarData = ToastBarData(text: error.localizedDescription, showSnackBar: true, messageType: .failure)
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
    
    private func logout() {
        
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.logout)

        Task {
            do {
                try await authService.logout(removeData: true)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                applicationStateService.state = .auth
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}
