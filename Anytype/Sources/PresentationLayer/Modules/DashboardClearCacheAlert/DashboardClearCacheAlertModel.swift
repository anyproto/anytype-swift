import Foundation
import AnytypeCore
import ProtobufMessages
import Combine
import UIKit

@MainActor
final class DashboardClearCacheAlertModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.fileActionsService)
    private var fileActionService: FileActionsServiceProtocol
    
    // MARK: - State
    
    @Published var toastBarData: ToastBarData = .empty
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenFileOffloadWarning()
    }
    
    func runClear() async throws {
        do {
            AnytypeAnalytics.instance().logSettingsStorageOffload()
            try await fileActionService.clearCache()
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.fileCacheCleared)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.toastBarData = ToastBarData(text: Loc.ClearCache.success, showSnackBar: true)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            throw error
        }
    }
}
