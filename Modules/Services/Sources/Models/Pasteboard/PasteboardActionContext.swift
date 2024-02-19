import Foundation

public enum PasteboardActionContext {
    case focused(String, NSRange)
    case selected([String])

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
