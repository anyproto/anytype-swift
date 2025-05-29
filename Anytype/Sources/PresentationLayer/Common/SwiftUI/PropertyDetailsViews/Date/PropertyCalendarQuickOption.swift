import Foundation

enum PropertyCalendarQuickOption: String, CaseIterable, Identifiable {
    case today
    case tomorrow
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .today: return Loc.today
        case .tomorrow: return Loc.tomorrow
        }
    }
    
    var date: Date {
        switch self {
        case .today: return Date()
        case .tomorrow: return Date.tomorrow
        }
    }
    
    var isLast: Bool {
        self == PropertyCalendarQuickOption.allCases.last
    }
}
