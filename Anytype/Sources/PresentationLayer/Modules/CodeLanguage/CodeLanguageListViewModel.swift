import Foundation
import Services

struct CodeLanguageListData: Identifiable, Hashable {
    let documentId: String
    let spaceId: String
    let blockId: String
    
    var id: Int { hashValue }
}

@MainActor
final class CodeLanguageListViewModel: ObservableObject {
    
    // MARK: - DI
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    
    private let data: CodeLanguageListData
    private lazy var document: any BaseDocumentProtocol = {
        documentsProvider.document(objectId: data.documentId, spaceId: data.spaceId)
    }()
    private var selectedLanguage: CodeLanguage?
    
    // MARK: - State
    
    @Published var rows: [CodeLanguageRowModel] = []
    @Published var dismiss: Bool = false
    
    init(data: CodeLanguageListData) {
        self.data = data
        let info = document.infoContainer.get(id: data.blockId)
        selectedLanguage = info?.fields.codeLanguage
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
            guard let info = document.infoContainer.get(id: data.blockId) else { return }
            let fields = CodeBlockFields(language: language)
            let newInfo = info.addFields(fields.asMiddleware())
            try await blockService.setFields(objectId: document.objectId, blockId: data.blockId, fields: newInfo.fields)
            dismiss.toggle()
        }
    }
    
    
}
