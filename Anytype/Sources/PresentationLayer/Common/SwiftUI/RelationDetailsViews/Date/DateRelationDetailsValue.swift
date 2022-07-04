import Foundation

enum DateRelationDetailsValue: CaseIterable, Hashable {
    
    case noDate
    case today
    case yesterday
    case tomorrow
    case exactDay
    
}

extension DateRelationDetailsValue {
    
    var title: String {
        switch self {
        case .noDate: return Loc.noDate
        case .today: return Loc.today
        case .yesterday: return Loc.yesterday
        case .tomorrow: return Loc.tomorrow
        case .exactDay: return Loc.exactDay
        }
    }
    
}
