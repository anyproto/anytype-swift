import BlocksModels

protocol EditorPageTemplatesHandlerProtocol {
    func didAppeared(with type: String?)
    func needShowTemplates(for document: BaseDocumentProtocol) -> Bool
    func onTemplatesShow()
}

final class EditorPageTemplatesHandler: EditorPageTemplatesHandlerProtocol {
    private var didShowTemplatesForType = false
    private var currentType: String?
    
    func didAppeared(with type: String?) {
        currentType = type
    }
    
    func needShowTemplates(for document: BaseDocumentProtocol) -> Bool {
        if currentType != document.details?.type {
            currentType = document.details?.type
            didShowTemplatesForType = false
        }
        
        return !didShowTemplatesForType
    }
    
    func onTemplatesShow() {
        didShowTemplatesForType = true
    }
}
