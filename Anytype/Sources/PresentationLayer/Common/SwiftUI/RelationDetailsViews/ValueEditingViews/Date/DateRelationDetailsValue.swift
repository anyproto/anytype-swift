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
        case .noDate: return "No date".localized
        case .today: return "Today".localized
        case .yesterday: return "Yesterday".localized
        case .tomorrow: return "Tomorrow".localized
        case .exactDay: return "Exact day".localized
        }
    }
    
}
