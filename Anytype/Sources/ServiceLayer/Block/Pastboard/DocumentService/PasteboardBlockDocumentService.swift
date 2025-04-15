import Services
import Foundation
import Combine


// Convenience wrapper of PasteboardBlockService
final class PasteboardBlockDocumentService: PasteboardBlockDocumentServiceProtocol, Sendable {
    
    private let service: any PasteboardBlockServiceProtocol = Container.shared.pasteboardBlockService()
    
    var hasValidURL: Bool {
        service.hasValidURL
    }
    
    func pasteInsideBlock(
        objectId: String,
        spaceId: String,
        focusedBlockId: String,
        range: NSRange,
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping @MainActor (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        service.pasteInsideBlock(
            objectId: objectId,
            spaceId: spaceId,
            focusedBlockId: focusedBlockId,
            range: range,
            handleLongOperation: handleLongOperation,
            completion: completion
        )
    }
    
    func pasteInSelectedBlocks(
        objectId: String,
        spaceId: String,
        selectedBlockIds: [String],
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping @MainActor (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        service.pasteInSelectedBlocks(
            objectId: objectId,
            spaceId: spaceId,
            selectedBlockIds: selectedBlockIds,
            handleLongOperation: handleLongOperation,
            completion: completion
        )
    }
    
    func copy(document: some BaseDocumentProtocol, blocksIds: [String], selectedTextRange: NSRange) async throws {
        let blockInformations = blocksIds.compactMap { document.infoContainer.get(id: $0) }
        try await service.copy(
            objectId: document.objectId,
            blockInfos: blockInformations,
            blocksIds: blocksIds,
            selectedTextRange: selectedTextRange
        )
    }
    
    func cut(document: some BaseDocumentProtocol, blocksIds: [String], selectedTextRange: NSRange) async throws {
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
