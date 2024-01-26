import Foundation
import Services

final class CodeLanguageListViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let document: BaseDocumentProtocol
    private let blockId: BlockId
    private let blockService: BlockServiceProtocol
    private let selectedLanguage: CodeLanguage
    
    // MARK: - State
    
    @Published var rows: [CodeLanguageRowModel] = []
    @Published var dismiss: Bool = false
    
    init(document: BaseDocumentProtocol, blockId: BlockId, selectedLanguage: CodeLanguage, blockService: BlockServiceProtocol) {
        self.document = document
        self.blockId = blockId
        self.selectedLanguage = selectedLanguage
        self.blockService = blockService
        updateRows(searchText: "")
    }
    
    func onChangeSearch(text: String) {
        updateRows(searchText: text)
    }
    
    // MARK: - Private
    
    private func updateRows(searchText: String) {

        let languages = searchText.isEmpty
            ? CodeLanguage.allCases
            : CodeLanguage.allCases.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        
        rows = languages.map { language in
            CodeLanguageRowModel(
                id: language.rawValue,
                title: language.title,
                isSelected: language == selectedLanguage
            ) { [weak self] in
                self?.onTapCodeLanguage(language)
            }
        }
    }
    
    private func onTapCodeLanguage(_ language: CodeLanguage) {
        Task { @MainActor in
            guard let info = document.infoContainer.get(id: blockId) else { return }
            let fields = CodeBlockFields(language: language)
            let newInfo = info.addFields(fields.asMiddleware())
            try await blockService.setFields(objectId: document.objectId, blockId: blockId, fields: newInfo.fields)
            dismiss.toggle()
        }
    }
    
    
}
