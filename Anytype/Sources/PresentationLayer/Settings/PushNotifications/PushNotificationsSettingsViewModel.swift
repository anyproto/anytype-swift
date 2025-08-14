import Foundation
import UIKit

@MainActor
final class PushNotificationsSettingsViewModel: ObservableObject {

    @Published var status: PushNotificationsSettingsStatus?
    
    @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol
    @Injected(\.pushNotificationsSystemSettingsBroadcaster)
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
