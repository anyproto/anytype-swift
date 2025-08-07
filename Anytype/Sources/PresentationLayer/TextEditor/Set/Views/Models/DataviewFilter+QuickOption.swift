import Services

extension DataviewFilter.QuickOption {
    var title: String {
        switch self {
        case .yesterday:
            return Loc.EditSet.Popup.Filter.Date.Option.yesterday
        case .today:
            return Loc.EditSet.Popup.Filter.Date.Option.today
        case .tomorrow:
            return Loc.EditSet.Popup.Filter.Date.Option.tomorrow
        case .lastWeek:
            return Loc.EditSet.Popup.Filter.Date.Option.lastWeek
        case .currentWeek:
            return Loc.EditSet.Popup.Filter.Date.Option.currentWeek
        case .nextWeek:
            return Loc.EditSet.Popup.Filter.Date.Option.nextWeek
        case .lastMonth:
            return Loc.EditSet.Popup.Filter.Date.Option.lastMonth
        case .currentMonth:
            return Loc.EditSet.Popup.Filter.Date.Option.currentMonth
        case .nextMonth:
            return Loc.EditSet.Popup.Filter.Date.Option.nextMonth
        case .numberOfDaysAgo:
            return Loc.EditSet.Popup.Filter.Date.Option.numberOfDaysAgo
        case .numberOfDaysNow:
            return Loc.EditSet.Popup.Filter.Date.Option.numberOfDaysFromNow
        case .exactDate:
            return Loc.EditSet.Popup.Filter.Date.Option.exactDate
        case .lastYear:
            return Loc.EditSet.Popup.Filter.Date.Option.lastYear
        case .currentYear:
            return Loc.EditSet.Popup.Filter.Date.Option.currentYear
        case .nextYear:
            return Loc.EditSet.Popup.Filter.Date.Option.nextYear
        case .UNRECOGNIZED:
            return ""
        }
    }
    
    static func orderedCases(for condition: DataviewFilter.Condition) -> [DataviewFilter.QuickOption] {
        switch condition {
        case .in:
            return Self.orderedInCases
        case .equal:
            return Self.orderedEqualCases
        default:
            return Self.defaultOrderedCases
        }
    }
    
    private static let defaultOrderedCases: [DataviewFilter.QuickOption] = [
        .today,
        .tomorrow,
        .yesterday,
        .currentWeek,
        .lastWeek,
        .nextWeek,
        .currentMonth,
        .lastMonth,
        .nextMonth,
        .lastYear,
        .currentYear,
        .nextYear,
        .numberOfDaysAgo,
        .numberOfDaysNow,
        .exactDate
    ]
    
    private static let orderedEqualCases: [DataviewFilter.QuickOption] = [
        .today,
        .tomorrow,
        .yesterday,
        .numberOfDaysAgo,
        .numberOfDaysNow,
        .exactDate
    ]
    
    private static let orderedInCases: [DataviewFilter.QuickOption] = [
        .today,
        .tomorrow,
        .yesterday,
        .currentWeek,
        .lastWeek,
        .nextWeek,
        .currentMonth,
        .lastMonth,
        .nextMonth,
        .lastYear,
        .currentYear,
        .nextYear
    ]
}
