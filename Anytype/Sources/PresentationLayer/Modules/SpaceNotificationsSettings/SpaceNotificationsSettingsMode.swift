import Services

enum SpaceNotificationsSettingsMode: CaseIterable {
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
        self == SpaceNotificationsSettingsMode.allCases.last
    }
}

extension SpaceNotificationsSettingsMode {
    var asPushNotificationsMode: SpacePushNotificationsMode {
        switch self {
        case .allActiviy: return .all
        case .mentions: return .mentions
        case .disabled: return .nothing
        }
    }
}

extension SpacePushNotificationsMode {
    var asNotificationsSettingsMode: SpaceNotificationsSettingsMode {
        switch self {
        case .all: return .allActiviy
        case .mentions: return .mentions
        case .nothing, .UNRECOGNIZED(_): return .disabled
        }
    }

    var isUnmutedAll: Bool {
        self == .all
    }

    var unreadCounterStyle: CounterViewStyle {
        switch self {
        case .all:
            return .highlighted
        case .mentions, .nothing, .UNRECOGNIZED:
            return .muted
        }
    }

    var mentionCounterStyle: MentionBadgeStyle {
        switch self {
        case .all, .mentions:
            return .highlighted
        case .nothing, .UNRECOGNIZED:
            return .muted
        }
    }

    var analyticsValue: String {
        switch self {
        case .all: return "All"
        case .mentions: return "Mentions"
        case .nothing: return "Nothing"
        case .UNRECOGNIZED(_): return ""
        }
    }
}
