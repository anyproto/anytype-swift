import Foundation
import Services

extension BlockWidget.Layout {
    var analyticsValue: String {
        switch self {
        case .link:
            return "Link"
        case .tree:
            return "Tree"
        case .list:
            return "List"
        }
    }
}
