import Foundation
import UIKit

@MainActor
@Observable
final class PushNotificationsSettingsViewModel {

    var status: PushNotificationsSettingsStatus?

    @ObservationIgnored @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol
    @ObservationIgnored @Injected(\.pushNotificationsSystemSettingsBroadcaster)
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol
    
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenAllowPushType(.settings)
    }
    func subscribeToSystemSettingsChanges() async {
        for await status in pushNotificationsSystemSettingsBroadcaster.statusStream {
            self.status = status.asPushNotificationsSettingsStatus
        }
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        AnytypeAnalytics.instance().logClickAllowPushType(.settings)
    }
}
