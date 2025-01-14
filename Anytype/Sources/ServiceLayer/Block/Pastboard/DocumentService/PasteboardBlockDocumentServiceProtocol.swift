import Services
import Foundation

protocol PasteboardBlockDocumentServiceProtocol: AnyObject, Sendable {
    var hasValidURL: Bool { get }
    
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
    
    func copy(document: some BaseDocumentProtocol, blocksIds: [String], selectedTextRange: NSRange) async throws
    func cut(document: some BaseDocumentProtocol, blocksIds: [String], selectedTextRange: NSRange) async throws
}
