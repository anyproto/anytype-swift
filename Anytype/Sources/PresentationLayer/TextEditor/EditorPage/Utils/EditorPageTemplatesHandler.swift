import BlocksModels

protocol EditorPageTemplatesHandlerProtocol {
    func didAppeared(with type: String?)
    func showTemplatesPopupWithTypeCheckIfNeeded(for document: BaseDocumentProtocol)
    func showTemplatesPopupIfNeeded(for document: BaseDocumentProtocol)
}

final class EditorPageTemplatesHandler: EditorPageTemplatesHandlerProtocol {
    private let router: EditorRouterProtocol
    private let objectsService: ObjectActionsServiceProtocol
    
    private var didShowTemplatesForType = false
    private var currentType: String?
    
    init(router: EditorRouterProtocol, objectsService: ObjectActionsServiceProtocol) {
        self.router = router
        self.objectsService = objectsService
    }
    
    func didAppeared(with type: String?) {
        currentType = type
    }
    
    func showTemplatesPopupWithTypeCheckIfNeeded(for document: BaseDocumentProtocol) {
        guard canShowTemplates(for: document) else { return }

        showTemplatesPopupIfNeeded(for: document)
    }
    
    func showTemplatesPopupIfNeeded(for document: BaseDocumentProtocol) {
        guard let typeURL = document.details?.objectType else { return }

        router.showTemplatesAvailabilityPopupIfNeeded(
            document: document,
            templatesTypeURL: .dynamic(typeURL.url),
            onShow: { [weak self] in
                self?.didShowTemplatesForType = true
            },
            onDismiss: { [weak self] in
                self?.resetTemplatesFlag(for: document)
            }
        )
    }
    
    private func canShowTemplates(for document: BaseDocumentProtocol) -> Bool {
        let needShowTypeMenu = document.details?.isSelectType ?? false &&
        !document.objectRestrictions.objectRestriction.contains(.typechange)
        
        if currentType != document.details?.type {
            currentType = document.details?.type
            didShowTemplatesForType = false
        }
        
        return !didShowTemplatesForType && !needShowTypeMenu
    }
    
    private func resetTemplatesFlag(for document: BaseDocumentProtocol) {
        guard let details = document.details else { return }
        
        objectsService.updateBundledDetails(
            contextID: details.id,
            details: [.internalFlags(details.internalFlagsWithoutTemplates)]
        )
    }
}
