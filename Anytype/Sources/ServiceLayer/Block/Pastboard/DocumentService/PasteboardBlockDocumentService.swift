import Services
import Foundation
import Combine


// Convenience wrapper of PasteboardBlockService
final class PasteboardBlockDocumentService: PasteboardBlockDocumentServiceProtocol {
    private let document: BaseDocumentProtocol
    private let service: PasteboardBlockServiceProtocol

    init(
        document: BaseDocumentProtocol,
        service: PasteboardBlockServiceProtocol
    ) {
        self.document = document
        self.service = service
    }
    
    var hasValidURL: Bool {
        service.hasValidURL
    }
    
    func pasteInsideBlock(
        focusedBlockId: String,
        range: NSRange,
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        service.pasteInsideBlock(
            objectId: document.objectId,
            focusedBlockId: focusedBlockId,
            range: range,
            handleLongOperation: handleLongOperation,
            completion: completion
        )
    }
    
    func pasteInSelectedBlocks(
        selectedBlockIds: [String],
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        service.pasteInSelectedBlocks(
            objectId: document.objectId,
            selectedBlockIds: selectedBlockIds,
            handleLongOperation: handleLongOperation,
            completion: completion
        )
    }
    
    func copy(blocksIds: [String], selectedTextRange: NSRange) async throws {
        let blockInformations = blocksIds.compactMap { document.infoContainer.get(id: $0) }
        try await service.copy(
            objectId: document.objectId,
            blockInfos: blockInformations,
            blocksIds: blocksIds,
            selectedTextRange: selectedTextRange
        )
    }
    
    func cut(blocksIds: [String], selectedTextRange: NSRange) async throws {
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
