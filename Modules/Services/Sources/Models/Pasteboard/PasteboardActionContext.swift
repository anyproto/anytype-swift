import Foundation

public enum PasteboardActionContext {
    case focused(BlockId, NSRange)
    case selected([BlockId])

    public var focusedBlockId: String {
        switch self {
        case .focused(let blockId, _):
            return blockId
        case .selected(_):
            return BlockId.empty
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

    public var selectedBlocksIds: [BlockId] {
        switch self {
        case .focused:
            return []
        case .selected(let blocksIds):
            return blocksIds
        }
    }
}
