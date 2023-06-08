import Foundation

enum WidgetInternalViewModelContext {
    case list
    case tree
    
    var maxItems: Int {
        switch self {
        case .list:
            return 3
        case .tree:
            return 12
        }
    }
}
