import Foundation
import UIKit

@MainActor
@Observable
final class DisabledPushNotificationsBannerViewModel {

    var requestAuthorizationId: String?
    var status: PushNotificationsSettingsStatus?

    @ObservationIgnored @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol
    @ObservationIgnored @Injected(\.pushNotificationsSystemSettingsBroadcaster)
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
        _ = await pushNotificationsPermissionService.requestAuthorizationAndRegisterIfNeeded()
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        AnytypeAnalytics.instance().logClickAllowPushType(.settings)
    }
}
