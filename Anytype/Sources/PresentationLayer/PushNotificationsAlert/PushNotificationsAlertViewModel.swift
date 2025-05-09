import Foundation
import UIKit
import UserNotifications

@MainActor
final class PushNotificationsAlertViewModel: ObservableObject {
    
    @Published var dismiss = false
    
    @Injected(\.pushNotificationsAlertHandler)
    private var pushNotificationsAlertHandler: any PushNotificationsAlertHandlerProtocol
    @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol
    
    func onAppear() {
        pushNotificationsAlertHandler.storeAlertShowDate()
    }
    
    func enablePushesTap() {
        dismiss.toggle()
        pushNotificationsPermissionService.requestAuthorization()
    }
    
    func laterTap() {
        dismiss.toggle()
    }
}
