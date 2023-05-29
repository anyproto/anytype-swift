import Foundation
import AnytypeCore
import ProtobufMessages
import Combine
import UIKit

@MainActor
final class DashboardClearCacheAlertModel: ObservableObject {
    
    // MARK: - DI
    
    private let alertOpener: AlertOpenerProtocol
    private let fileActionService: FileActionsServiceProtocol
    
    // MARK: - State
    
    @Published var toastBarData: ToastBarData = .empty
        
    init(alertOpener: AlertOpenerProtocol, fileActionService: FileActionsServiceProtocol) {
        self.alertOpener = alertOpener
        self.fileActionService = fileActionService
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.clearFileCacheAlertShow)
    }
    
    func runClear(dismiss: @MainActor @escaping () -> Void) {
        
        let alertDismiss = alertOpener.showLoadingAlert(message: Loc.removingCache)
        
        Task {
            do {
                try await fileActionService.clearCache()
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.fileCacheCleared)
                alertDismiss()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self.toastBarData = ToastBarData(text: Loc.ClearCache.success, showSnackBar: true)
                dismiss()
            } catch {
                alertDismiss()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                self.toastBarData = ToastBarData(text: Loc.ClearCache.error, showSnackBar: true)
            }
        }
    }
}
