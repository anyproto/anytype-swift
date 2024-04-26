import Foundation

public struct PasteboardPasteResult {
    public let caretPosition: Int
    public let isSameBlockCaret: Bool
    public let blockIds: [BlockId]
}
