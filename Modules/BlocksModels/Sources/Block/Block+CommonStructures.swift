import Foundation

public enum BlockKind {
    case meta
    case block
}

public enum BlockPosition {
    case none
    case top, bottom
    case left, right
    case inner
    case replace
}

public enum BlockFocusPosition {
    case unknown
    case beginning
    case end
    case at(Int)
}

