import Foundation
import UserNotifications
import UIKit
import AnytypeCore

enum PushNotificationsPermissionStatus {
    case notDetermined
    case denied
    case authorized
    case unknown
}

protocol PushNotificationsPermissionServiceProtocol: AnyObject, Sendable {
    func authorizationStatus() async -> PushNotificationsPermissionStatus
    func requestAuthorization()
    func registerForRemoteNotificationsIfNeeded() async
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
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            if granted {
                self?.registerForRemoteNotifications()
            }
        }
    }
    
    func registerForRemoteNotificationsIfNeeded() async {
        guard FeatureFlags.enablePushMessages else { return }
        
        let status = await authorizationStatus()
        if status == .authorized {
            registerForRemoteNotifications()
        }
    }
    
    private func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
