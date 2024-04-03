import Foundation
import AnytypeCore
import ProtobufMessages
import Combine
import UIKit

@MainActor
final class DashboardClearCacheAlertModel: ObservableObject {
    
    // MARK: - DI
    
    private let alertOpener: AlertOpenerProtocol
    @Injected(\.fileActionsService)
    private var fileActionService: FileActionsServiceProtocol
    
    // MARK: - State
    
    @Published var toastBarData: ToastBarData = .empty
        
    init(alertOpener: AlertOpenerProtocol) {
        self.alertOpener = alertOpener
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenFileOffloadWarning()
    }
    
    func runClear(dismiss: @MainActor @escaping () -> Void) {
        
        let alertDismiss = alertOpener.showLoadingAlert(message: Loc.removingCache)
        
        Task {
            do {
                AnytypeAnalytics.instance().logSettingsStorageOffload()
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
