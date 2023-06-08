import Foundation

enum WidgetInternalViewModelContext {
    case list
    case tree
    case compactList
    
    var maxItems: Int {
        switch self {
        case .list:
            return 3
        case .tree:
            return 12
        case .compactList:
            return 10
        }
    }
}
