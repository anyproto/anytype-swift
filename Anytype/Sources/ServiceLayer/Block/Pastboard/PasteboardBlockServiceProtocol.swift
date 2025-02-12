import Services
import Foundation

protocol PasteboardBlockServiceProtocol: AnyObject, Sendable {
    var hasValidURL: Bool { get }
    var pasteboardContent: PasteboardContent? { get }
    
    func pasteInsideBlock(
        objectId: String,
        spaceId: String,
        focusedBlockId: String,
        range: NSRange,
        handleLongOperation: @escaping () -> Void,
        completion: @escaping @Sendable @MainActor (_ pasteResult: PasteboardPasteResult?) -> Void
    )
    func pasteInSelectedBlocks(
        objectId: String,
        spaceId: String,
        selectedBlockIds: [String],
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping @Sendable @MainActor (_ pasteResult: PasteboardPasteResult?) -> Void
    )
    
    func copy(
        objectId: String,
        blockInfos: [BlockInformation],
        blocksIds: [String],
        selectedTextRange: NSRange
    ) async throws
    
    func cut(
        objectId: String,
        blockInfos: [BlockInformation],
        blocksIds: [String],
        selectedTextRange: NSRange
    ) async throws
}
