import Foundation
import Services
import FirebaseMessaging

protocol RegistrationPushNotificationsServiceProtocol: AnyObject, Sendable {
    func registerForPushNotifications()
}

final class RegistrationPushNotificationsService: RegistrationPushNotificationsServiceProtocol {
    
    private let pushNotificationsService: any PushNotificationsServiceProtocol = Container.shared.pushNotificationsService()
    
    // MARK: - RegistrationPushNotificationsServiceProtocol
    
    func registerForPushNotifications() {
        Task {
            let token = try await Messaging.messaging().token()
            try await pushNotificationsService.pushNotificationRegisterToken(token: token)
        }
    }
}
