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
            guard range.location != NSNotFound else { return .init(location: 0, length: 0) }
            let textRange = NSRange(location: 0, length: text.length + 1)
            if let validSelectedRange = range.intersection(textRange) {
                return validSelectedRange
            }
            // A position entirely past the end means the text it was computed for has not been
            // applied yet — a paste response reaches the text view before the middleware echo
            // carrying the pasted characters. Clamping to the end keeps the intent; answering
            // "put the caret at offset N" with offset 0 reads as the caret jumping to the top
            // of the block.
            return .init(location: text.length, length: 0)
        }
    }
}

