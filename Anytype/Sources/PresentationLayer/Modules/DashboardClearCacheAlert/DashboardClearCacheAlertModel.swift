import Foundation
import AnytypeCore
import ProtobufMessages
import Combine
import UIKit

@MainActor
final class DashboardClearCacheAlertModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.fileActionsService)
    private var fileActionService: any FileActionsServiceProtocol
    
    // MARK: - State
    
    @Published var toastBarData: ToastBarData?
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenFileOffloadWarning()
    }
    
    func runClear() async throws {
        do {
            AnytypeAnalytics.instance().logSettingsStorageOffload()
            try await fileActionService.clearCache()
            AnytypeAnalytics.instance().logFileOffload()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.toastBarData = ToastBarData(Loc.ClearCache.success)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            throw error
        }
    }
}
