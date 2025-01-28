import SwiftUI

enum MessageViewSpacing {
    case small
    case medium
    case disable
}

extension MessageViewSpacing {
    var height: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 12
        case .disable: return 0
        }
    }
}
