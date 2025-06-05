import Foundation
import AnytypeCore

protocol PushNotificationsAlertHandlerProtocol: AnyObject, Sendable {
    func shouldShowAlert() async -> Bool
    func storeAlertShowDate()
}

final class PushNotificationsAlertHandler: PushNotificationsAlertHandlerProtocol, @unchecked Sendable {
    
    private let pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol = Container.shared.pushNotificationsPermissionService()
    private let serverConfigurationStorage: any ServerConfigurationStorageProtocol = Container.shared.serverConfigurationStorage()
    
    // [Date]
    @UserDefault("UserData.PushNotificationsAlertDates", defaultValue: [])
    private var pushNotificationsAlertDates: [Date]
    
    // MARK: - PushNotificationsAlertHandlerProtocol
    
    func shouldShowAlert() async -> Bool {
        guard FeatureFlags.enablePushMessages else {
            return false
        }
        
        guard serverConfigurationStorage.currentConfiguration() != .localOnly else {
            return false
        }
        
        let status = await pushNotificationsPermissionService.authorizationStatus()
        
        switch status {
        case .notDetermined:
            return limitationsHasPassed()
        case .denied, .authorized, .unknown:
            return false
        }
    }
    
    func storeAlertShowDate() {
        pushNotificationsAlertDates.append(Date())
    }
    
    // MARK: - Private
    
    private func limitationsHasPassed() -> Bool {        
        pushNotificationsAlertDates.isEmpty
    }
}
