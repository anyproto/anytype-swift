import Foundation
import Services
import SwiftUI

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

extension LayoutAlignment {
    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .left, .justify, .UNRECOGNIZED:
            return .leading
        case .center:
            return .center
        case .right:
            return .trailing
        }
    }
}

