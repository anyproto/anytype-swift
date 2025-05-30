enum NotificationsSettingsMode {
    case authorized
    case denied
    case notDetermined
}

extension PushNotificationsPermissionStatus {
    var asNotificationsSettingsMode: NotificationsSettingsMode {
        switch self {
        case .notDetermined, .unknown: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        }
    }
}
