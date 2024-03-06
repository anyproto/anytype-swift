import Services
import Foundation

protocol PasteboardBlockServiceProtocol: AnyObject {
    var hasValidURL: Bool { get }
    var pasteboardContent: PasteboardContent? { get }
    
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
