import Foundation
import UIKit
import AnytypeCore

@MainActor
@Observable
final class PushNotificationsSettingsViewModel {

    var status: PushNotificationsSettingsStatus?
    var sendTypingIndicator = Container.shared.userDefaultsStorage().sendTypingIndicator
    let showTypingSetting = FeatureFlags.chatActivity

    @ObservationIgnored @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol
    @ObservationIgnored @Injected(\.pushNotificationsSystemSettingsBroadcaster)
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol
    @ObservationIgnored @Injected(\.chatActivityStore)
    private var chatActivityStore: any ChatActivityStoreProtocol
    
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenAllowPushType(.settings)
    }
    func subscribeToSystemSettingsChanges() async {
        for await status in pushNotificationsSystemSettingsBroadcaster.statusStream {
            self.status = status.asPushNotificationsSettingsStatus
        }
    }
    
    /// "Show others when I'm typing": per device. Off stops publishing; others' typing still shows.
    func onSendTypingToggled(_ value: Bool) {
        sendTypingIndicator = value
        chatActivityStore.setSendTypingEnabled(value)
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        AnytypeAnalytics.instance().logClickAllowPushType(.settings)
    }
}
