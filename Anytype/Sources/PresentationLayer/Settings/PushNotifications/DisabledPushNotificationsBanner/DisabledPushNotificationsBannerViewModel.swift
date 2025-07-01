import Foundation
import UIKit

@MainActor
final class DisabledPushNotificationsBannerViewModel: ObservableObject {
    
    @Published var requestAuthorizationId: String?
    @Published var status: PushNotificationsSettingsStatus?
    
    @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol
    @Injected(\.pushNotificationsSystemSettingsBroadcaster)
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol
    

    func subscribeToSystemSettingsChanges() async {
        for await status in pushNotificationsSystemSettingsBroadcaster.statusStream {
            self.status = status.asPushNotificationsSettingsStatus
        }
    }
    
    func enableNotificationsTap() {
        requestAuthorizationId = UUID().uuidString
        AnytypeAnalytics.instance().logClickAllowPushType(.enableNotifications)
    }
    
    func requestAuthorization() async {
        _ = await pushNotificationsPermissionService.requestAuthorization()
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        AnytypeAnalytics.instance().logClickAllowPushType(.settings)
    }
}
