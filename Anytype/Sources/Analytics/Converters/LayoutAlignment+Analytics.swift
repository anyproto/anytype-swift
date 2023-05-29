import Foundation
import BlocksModels

public extension LayoutAlignment {
    var analyticsValue: String {
        switch self {
        case .left:
            return "Left"
        case .center:
            return "Center"
        case .right:
            return "Right"
        }
    }
}
