import Services
import Foundation

protocol PasteboardBlockDocumentServiceProtocol: AnyObject {
    var hasValidURL: Bool { get }
    
    func pasteInsideBlock(
        focusedBlockId: String,
        range: NSRange,
        handleLongOperation: @escaping () -> Void,
        completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void
    )
    func pasteInSelectedBlocks(
        selectedBlockIds: [String],
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void
    )
    
    func copy(blocksIds: [String], selectedTextRange: NSRange) async throws
    func cut(blocksIds: [String], selectedTextRange: NSRange) async throws
}
