import Foundation

public protocol PasteboardMiddlewareServiceProtocol: AnyObject {
    
    func pasteText(_ text: String, objectId: BlockId, context: PasteboardActionContext) async throws -> PasteboardPasteResult

    func pasteHTML(_ html: String, objectId: BlockId, context: PasteboardActionContext) async throws -> PasteboardPasteResult

    func pasteBlock(_ blocks: [String], objectId: BlockId, context: PasteboardActionContext) async throws -> PasteboardPasteResult

    func pasteFiles(_ files: [PasteboardFile], objectId: BlockId, context: PasteboardActionContext) async throws -> PasteboardPasteResult

    func copy(blockInformations: [BlockInformation], objectId: BlockId, selectedTextRange: NSRange) async throws -> PasteboardCopyResult?
    
    func cut(blockInformations: [BlockInformation], objectId: BlockId, selectedTextRange: NSRange) async throws -> PasteboardCopyResult?
}
