import Foundation
import Services

extension BlockWidget.Layout {
    var limits: [Int] {
        switch self {
        case .link, .UNRECOGNIZED:
            return [0]
        case .list, .view:
            return [4, 6, 8]
        case .compactList, .tree:
            return [6, 10, 14]
        }
    }
}
