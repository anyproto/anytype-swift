import Foundation
import UIKit

@MainActor
final class NotificationsSettingsViewModel: ObservableObject {
    
    @Published var requestAuthorizationId: String?
    @Published var dismiss = false
    @Published var mode: NotificationsSettingsMode?
    
    @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol
    
    func checkStatus() async {
        let status = await pushNotificationsPermissionService.authorizationStatus()
        mode = status.asNotificationsSettingsMode
    }
    
    func enableNotificationsTap() {
        requestAuthorizationId = UUID().uuidString
    }
    
    func requestAuthorization() async {
        let granted = await pushNotificationsPermissionService.requestAuthorization()
        mode = granted ? .authorized : .denied
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
