import Foundation
import UserNotifications

enum PushNotificationsPermissionStatus {
    case notDetermined
    case denied
    case authorized
    case unknown
}

protocol PushNotificationsPermissionServiceProtocol: AnyObject, Sendable {
    func authorizationStatus() async -> PushNotificationsPermissionStatus
}

final class PushNotificationsPermissionService: PushNotificationsPermissionServiceProtocol {
    
    // MARK: - PushNotificationsPermissionServiceProtocol
    
    func authorizationStatus() async -> PushNotificationsPermissionStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized, .provisional, .ephemeral:
            return .authorized
        @unknown default:
            return .unknown
        }
    }
}
