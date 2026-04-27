import Services
import AnytypeCore

extension SpacePushNotificationsMode {

    static var displayModes: [SpacePushNotificationsMode] {
        [.all, .mentions, .nothing]
    }

    var title: String {
        switch self {
        case .all: return Loc.Space.Notifications.Settings.State.enable
        case .mentions: return Loc.Space.Notifications.Settings.State.mentions
        case .nothing, .UNRECOGNIZED: return Loc.disabled
        }
    }

    var titleShort: String {
        switch self {
        case .all: return Loc.Space.Notifications.Settings.State.enable
        case .mentions: return Loc.Space.Notifications.Settings.State.mentions
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

    func toggled(isOneToOne: Bool) -> SpacePushNotificationsMode {
        guard isUnmutedAll else { return .all }
        return isOneToOne ? .nothing : .mentions
    }

    var unreadCounterStyle: CounterViewStyle {
        switch self {
        case .all:
            return .highlighted
        case .mentions, .nothing, .UNRECOGNIZED:
            return .muted
        }
    }

    var mentionCounterStyle: BadgeStyle {
        switch self {
        case .all, .mentions:
            return .highlighted
        case .nothing, .UNRECOGNIZED:
            return .muted
        }
    }

    /// Hidden in `.nothing` mode when `FeatureFlags.muteAndHide` is on.
    /// Mention-only (unsubscribed) parents pass `isSubscribed: false` to drop the counter regardless of mode.
    func shouldShowUnreadCounter(unreadCount: Int, isSubscribed: Bool = true) -> Bool {
        guard isSubscribed, unreadCount > 0 else { return false }
        guard FeatureFlags.muteAndHide else { return true }
        return self != .nothing
    }

    var reactionCounterStyle: BadgeStyle {
        switch self {
        case .all:
            return .highlighted
        case .mentions, .nothing, .UNRECOGNIZED:
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
