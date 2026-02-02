import Services

extension SpacePushNotificationsMode {

    static var displayModes: [SpacePushNotificationsMode] {
        [.all, .mentions, .nothing]
    }

    var title: String {
        switch self {
        case .all: return Loc.Space.Notifications.Settings.State.all
        case .mentions: return Loc.Space.Notifications.Settings.State.mentions
        case .nothing, .UNRECOGNIZED: return Loc.Space.Notifications.Settings.State.disabled
        }
    }

    var titleShort: String {
        switch self {
        case .all: return Loc.all
        case .mentions: return Loc.mentions
        case .nothing, .UNRECOGNIZED: return Loc.disabled
        }
    }

    var isEnabled: Bool {
        self != .nothing
    }

    var isLast: Bool {
        self == Self.displayModes.last
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
