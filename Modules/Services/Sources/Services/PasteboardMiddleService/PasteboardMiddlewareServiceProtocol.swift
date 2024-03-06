import Foundation

public protocol PasteboardMiddlewareServiceProtocol: AnyObject {
    
    func pasteText(_ text: String, objectId: String, context: PasteboardActionContext) async throws -> PasteboardPasteResult

    func pasteHTML(_ html: String, objectId: String, context: PasteboardActionContext) async throws -> PasteboardPasteResult

    func pasteBlock(_ blocks: [String], objectId: String, context: PasteboardActionContext) async throws -> PasteboardPasteResult

    func pasteFiles(_ files: [PasteboardFile], objectId: String, context: PasteboardActionContext) async throws -> PasteboardPasteResult

    func copy(blockInformations: [BlockInformation], objectId: String, selectedTextRange: NSRange) async throws -> PasteboardCopyResult?
    
    func cut(blockInformations: [BlockInformation], objectId: String, selectedTextRange: NSRange) async throws -> PasteboardCopyResult?
}
