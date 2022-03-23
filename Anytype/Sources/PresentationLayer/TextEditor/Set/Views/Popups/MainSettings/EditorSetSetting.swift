import SwiftUI

enum EditorSetSetting: CaseIterable, Identifiable {
    var id: String { name }
    
//    case view
    case settings
//    case sort
//    case filter
//    case group
    
    var name: String {
        switch self {
//        case .view:
//            return "View".localized
        case .settings:
            return "Settings".localized
//        case .sort:
//            return "Sort".localized
//        case .filter:
//            return "Filter".localized
//        case .group:
//            return "Group".localized
        }
    }
    
    var image: Image {
        switch self {
//        case .view:
//            return .set.view
        case .settings:
            return .set.viewSettings
//        case .sort:
//            return .set.sort
//        case .filter:
//            return .set.filter
//        case .group:
//            return .set.group
        }
    }
}
