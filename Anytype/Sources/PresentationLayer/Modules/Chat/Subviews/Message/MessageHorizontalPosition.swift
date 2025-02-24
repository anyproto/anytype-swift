import Foundation

enum MessageHorizontalPosition: Hashable, Equatable {
    case left
    case right
}

extension MessageHorizontalPosition {
    var isRight: Bool {
        self == .right
    }
    
    var isLeft: Bool {
        self == .left
    }
}
