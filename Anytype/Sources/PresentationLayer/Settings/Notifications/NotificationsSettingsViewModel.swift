import Foundation
import UIKit

@MainActor
final class NotificationsSettingsViewModel: ObservableObject {
    
    @Published var requestAuthorizationId: String?
    @Published var mode: NotificationsSettingsMode?
    
    @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol
    @Injected(\.pushNotificationsSystemSettingsBroadcaster)
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol
    
    func subscribeToSystemSettingsChanges() async {
        for await status in pushNotificationsSystemSettingsBroadcaster.statusStream {
            mode = status.asNotificationsSettingsMode
        }
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
