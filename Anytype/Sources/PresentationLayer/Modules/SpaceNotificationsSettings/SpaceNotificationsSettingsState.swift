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
