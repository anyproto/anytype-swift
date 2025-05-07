import Foundation
import Services
import FirebaseMessaging

protocol PushNotificationsRegistrationServiceProtocol: AnyObject, Sendable {
    func registerForPushNotifications()
}

final class PushNotificationsRegistrationService: PushNotificationsRegistrationServiceProtocol {
    
    private let pushNotificationsService: any PushNotificationsServiceProtocol = Container.shared.pushNotificationsService()
    
    // MARK: - RegistrationPushNotificationsServiceProtocol
    
    func registerForPushNotifications() {
        Task {
            let token = try await Messaging.messaging().token()
            try await pushNotificationsService.pushNotificationRegisterToken(token: token)
        }
    }
}
