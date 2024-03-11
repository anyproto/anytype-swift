import Foundation


public enum BlockKind {
    case meta
    case block
}

public enum BlockFocusPosition: Equatable, Hashable {
    case beginning
    case end
    case at(NSRange)
}

public extension BlockFocusPosition {
    func toSelectedRange(in text: NSString) -> NSRange {
        switch self {
        case .beginning:
            return .init(location: 0, length: 0)
        case .end:
            return .init(location: text.length, length: 0)

        case let .at(range):
            let textRange = NSRange(location: 0, length: text.length + 1)
            let validSelectedRange = range.intersection(textRange)
            return validSelectedRange ?? .init(location: 0, length: 0)
        }
    }
}

