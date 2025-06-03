enum PushNotificationsSettingsMode {
    case authorized
    case denied
    case notDetermined
}

extension PushNotificationsPermissionStatus {
    var asPushNotificationsSettingsMode: PushNotificationsSettingsMode {
        switch self {
        case .notDetermined, .unknown: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        }
    }
}
