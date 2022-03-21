import SwiftUI

enum EditorSetSettings: CaseIterable, Identifiable {
    var id: String { name }
    
//    case view
    case settings
    case sort
    case filter
//    case group
    
    var name: String {
        switch self {
        case .settings:
            return "Settings".localized
        case .sort:
            return "Sort".localized
        case .filter:
            return "Filter".localized
        }
    }
    
    var image: Image {
        switch self {
        case .settings:
            return .set.viewSettings
        case .sort:
            return .set.sort
        case .filter:
            return .set.filter
        }
    }
}
