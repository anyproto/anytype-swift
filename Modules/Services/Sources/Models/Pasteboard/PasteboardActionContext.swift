import Foundation

public enum PasteboardActionContext: Sendable {
    case focused(blockId: String, range: NSRange)
    case selected(blockIds: [String])

    public var focusedBlockId: String {
        switch self {
        case .focused(let blockId, _):
            return blockId
        case .selected(_):
            return ""
        }
    }

    public var selectedRange: NSRange {
        switch self {
        case .focused(_, let nSRange):
            return nSRange
        case .selected:
            return NSRange()
        }
    }

    public var selectedBlocksIds: [String] {
        switch self {
        case .focused:
            return []
        case .selected(let blocksIds):
            return blocksIds
        }
    }
}
