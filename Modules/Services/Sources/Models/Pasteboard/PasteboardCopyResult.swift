import Foundation

public struct PasteboardCopyResult: Sendable {
    public let textSlot: String
    public let htmlSlot: String
    public let blockSlot: [String]
}
