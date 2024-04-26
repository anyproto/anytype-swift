import Foundation
import Services

final class CodeLanguageLegacyListViewModel {
    
    var items: [CodeLanguage] = CodeLanguage.allCases
    
    private let document: BaseDocumentProtocol
    private let blockId: BlockId
    private let blockService: BlockServiceProtocol
    
    init(document: BaseDocumentProtocol, blockId: BlockId, blockService: BlockServiceProtocol) {
        self.document = document
        self.blockId = blockId
        self.blockService = blockService
    }
    
    func onTapCodeLanguage(_ language: CodeLanguage) {
        Task { @MainActor in
            guard let info = document.infoContainer.get(id: blockId) else { return }
            let fields = CodeBlockFields(language: language)
            let newInfo = info.addFields(fields.asMiddleware())
            try await blockService.setFields(objectId: document.objectId, blockId: blockId, fields: newInfo.fields)
        }
    }
}
