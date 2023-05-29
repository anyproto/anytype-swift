import Foundation
import BlocksModels

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
