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
    case beginning
    case end
    case at(NSRange)

    init(_ selectedRange: NSRange, textLength: Int) {
        let caretLocation = selectedRange.location

        if caretLocation == 0, selectedRange.length == 0 {
            self = .beginning
        } else if caretLocation - 1 == textLength, selectedRange.length == 0 {
            self = .end
        }
        self = .at(selectedRange)
    }
}

public extension BlockFocusPosition {
    func toSelectedRange(in text: String) -> NSRange {
        switch self {
        case .beginning:
            return .init(location: 0, length: 0)
        case .end:
            return .init(location: text.count, length: 0)
        case let .at(range):
            let textRange = NSRange(location: 0, length: text.count + 1)
            let validSelectedRange = range.intersection(textRange)
            return validSelectedRange ?? .init(location: 0, length: 0)
        }
    }
}

