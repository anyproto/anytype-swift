import Services

enum SpaceNotificationsSettingsState: CaseIterable {
    case allActiviy
    case mentions
    case disabled
    
    var title: String {
        switch self {
        case .allActiviy:
            return Loc.Space.Notifications.Settings.State.all
        case .mentions:
            return Loc.Space.Notifications.Settings.State.mentions
        case .disabled:
            return Loc.Space.Notifications.Settings.State.disabled
        }
    }
    
    var titleShort: String {
        switch self {
        case .allActiviy:
            return Loc.all
        case .mentions:
            return Loc.mentions
        case .disabled:
            return Loc.disabled
        }
    }
    
    var isEnabled: Bool {
        self != .disabled
    }
    
    var isLast: Bool {
        self == SpaceNotificationsSettingsState.allCases.last
    }
}

extension SpaceNotificationsSettingsState {
    var asPushNotificationsMode: SpacePushNotificationsMode {
        switch self {
        case .allActiviy: return .all
        case .mentions: return .mentions
        case .disabled: return .nothing
        }
    }
}

extension SpacePushNotificationsMode {
    var asNotificationsSettingsState: SpaceNotificationsSettingsState {
        switch self {
        case .all: return .allActiviy
        case .mentions: return .mentions
        case .nothing, .UNRECOGNIZED(_): return .disabled
        }
    }
    
    var isUnmutedAll: Bool {
        self == .all
    }
}
