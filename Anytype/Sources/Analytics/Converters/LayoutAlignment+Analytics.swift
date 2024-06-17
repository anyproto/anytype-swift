import Foundation
import Services

public extension LayoutAlignment {
    var analyticsValue: String {
        switch self {
        case .left:
            return "Left"
        case .center:
            return "Center"
        case .right:
            return "Right"
        case .justify:
            return "Justify"
        case .UNRECOGNIZED:
            return "UNRECOGNIZED"
        }
    }
}
