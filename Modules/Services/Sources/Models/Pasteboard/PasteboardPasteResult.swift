import Foundation

public struct PasteboardPasteResult: Sendable {
    public let caretPosition: Int
    public let isSameBlockCaret: Bool
    public let blockIds: [String]
}
