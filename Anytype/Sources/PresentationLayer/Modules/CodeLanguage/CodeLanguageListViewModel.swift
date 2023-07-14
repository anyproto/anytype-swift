import Foundation
import Services

final class CodeLanguageListViewModel {
    
    var items: [CodeLanguage] = CodeLanguage.allCases
    
    private let document: BaseDocumentProtocol
    private let blockId: BlockId
    private let blockListService: BlockListServiceProtocol
    
    init(document: BaseDocumentProtocol, blockId: BlockId, blockListService: BlockListServiceProtocol) {
        self.document = document
        self.blockId = blockId
        self.blockListService = blockListService
    }
    
    func onTapCodeLanguage(_ language: CodeLanguage) {
        Task { @MainActor in
            guard let info = document.infoContainer.get(id: blockId) else { return }
            let fields = CodeBlockFields(language: language)
            let newInfo = info.addFields(fields.asMiddleware())
            try await blockListService.setFields(objectId: document.objectId, blockId: blockId, fields: newInfo.fields)
        }
    }
}
