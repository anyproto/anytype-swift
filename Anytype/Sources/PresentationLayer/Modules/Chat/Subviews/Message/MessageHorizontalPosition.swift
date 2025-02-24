import Foundation

enum MessageHorizontalPosition: Hashable, Equatable {
    case left
    case right
}

extension MessageHorizontalPosition {
    var isRight: Bool {
        switch self {
        case .right:
            return true
        default:
            return false
        }
    }
    
    var isLeft: Bool {
        switch self {
        case .left:
            return true
        default:
            return false
        }
    }
}
