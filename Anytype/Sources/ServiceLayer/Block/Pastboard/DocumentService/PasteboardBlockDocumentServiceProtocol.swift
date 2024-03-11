import Services
import Foundation

protocol PasteboardBlockDocumentServiceProtocol: AnyObject {
    var hasValidURL: Bool { get }
    
    func pasteInsideBlock(
        objectId: String,
        focusedBlockId: String,
        range: NSRange,
        handleLongOperation: @escaping () -> Void,
        completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void
    )
    func pasteInSelectedBlocks(
        objectId: String,
        selectedBlockIds: [String],
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void
    )
    
    func copy(document: BaseDocumentProtocol, blocksIds: [String], selectedTextRange: NSRange) async throws
    func cut(document: BaseDocumentProtocol, blocksIds: [String], selectedTextRange: NSRange) async throws
}
