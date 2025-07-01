enum PushNotificationsSettingsStatus {
    case authorized
    case denied
    case notDetermined
    
    var isAuthorized: Bool {
        self == .authorized
    }
}

extension PushNotificationsPermissionStatus {
    var asPushNotificationsSettingsStatus: PushNotificationsSettingsStatus {
        switch self {
        case .notDetermined, .unknown: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        }
    }
}
