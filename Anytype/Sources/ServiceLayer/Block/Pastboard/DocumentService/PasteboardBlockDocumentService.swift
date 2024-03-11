import Services
import Foundation
import Combine


// Convenience wrapper of PasteboardBlockService
final class PasteboardBlockDocumentService: PasteboardBlockDocumentServiceProtocol {
    
    @Injected(\.pasteboardBlockService)
    private var service: PasteboardBlockServiceProtocol
    
    var hasValidURL: Bool {
        service.hasValidURL
    }
    
    func pasteInsideBlock(
        objectId: String,
        focusedBlockId: String,
        range: NSRange,
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        service.pasteInsideBlock(
            objectId: objectId,
            focusedBlockId: focusedBlockId,
            range: range,
            handleLongOperation: handleLongOperation,
            completion: completion
        )
    }
    
    func pasteInSelectedBlocks(
        objectId: String,
        selectedBlockIds: [String],
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        service.pasteInSelectedBlocks(
            objectId: objectId,
            selectedBlockIds: selectedBlockIds,
            handleLongOperation: handleLongOperation,
            completion: completion
        )
    }
    
    func copy(document: BaseDocumentProtocol, blocksIds: [String], selectedTextRange: NSRange) async throws {
        let blockInformations = blocksIds.compactMap { document.infoContainer.get(id: $0) }
        try await service.copy(
            objectId: document.objectId,
            blockInfos: blockInformations,
            blocksIds: blocksIds,
            selectedTextRange: selectedTextRange
        )
    }
    
    func cut(document: BaseDocumentProtocol, blocksIds: [String], selectedTextRange: NSRange) async throws {
        let blockInformations = blocksIds.compactMap { document.infoContainer.get(id: $0) }
        try await service.cut(
            objectId: document.objectId,
            blockInfos: blockInformations,
            blocksIds: blocksIds,
            selectedTextRange: selectedTextRange
        )
    }
}

private extension PasteboardBlockDocumentService {
    enum Constants {
        static let longOperationTime: Double = 0.5
    }
}
