import Foundation
import UIKit

struct PushNotificationsAlertData: Identifiable {
    let id = UUID()
    let completion: (_ granted: Bool) -> Void
}

@MainActor
@Observable
final class PushNotificationsAlertViewModel {

    var dismiss = false
    var requestAuthorizationId: String?

    @ObservationIgnored @Injected(\.pushNotificationsAlertHandler)
    private var pushNotificationsAlertHandler: any PushNotificationsAlertHandlerProtocol
    @ObservationIgnored @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol

    @ObservationIgnored
    private let data: PushNotificationsAlertData
    
    init(data: PushNotificationsAlertData) {
        self.data = data
    }
    
    func onAppear() {
        pushNotificationsAlertHandler.storeAlertShowDate()
        AnytypeAnalytics.instance().logScreenAllowPushType(.initial)
    }
    
    func enablePushesTap() {
        requestAuthorizationId = UUID().uuidString
        AnytypeAnalytics.instance().logClickAllowPushType(.enableNotifications)
    }
    
    func laterTap() {
        dismiss.toggle()
    }
    
    func requestAuthorization() async  {
        let granted = await pushNotificationsPermissionService.requestAuthorizationAndRegisterIfNeeded()
        data.completion(granted)
        dismiss.toggle()
    }
}
