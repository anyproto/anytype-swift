import Foundation
import UIKit

struct PushNotificationsAlertData: Identifiable {
    let id = UUID()
    let completion: (_ granted: Bool) -> Void
}

@MainActor
final class PushNotificationsAlertViewModel: ObservableObject {
    
    @Published var dismiss = false
    @Published var requestAuthorizationId: String?
    
    @Injected(\.pushNotificationsAlertHandler)
    private var pushNotificationsAlertHandler: any PushNotificationsAlertHandlerProtocol
    @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol
    
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
    }
    
    func laterTap() {
        dismiss.toggle()
    }
    
    func requestAuthorization() async  {
        let granted = await pushNotificationsPermissionService.requestAuthorization()
        data.completion(granted)
        dismiss.toggle()
    }
}
