import Services

extension EditorPageViewModel {
    func onChangeType(typeSelection: TypeSelectionResult) {
        switch typeSelection {
        case .object(let type, let pasteContent):
            onChangeType(type: type, pasteContent: pasteContent)
        case .bookmark(let url):
            onChangeTypeToBookmark(url: url)
        }
    }
    
    private func onChangeType(type: ObjectType, pasteContent: Bool) {
        if type.isSetType {
            Task { @MainActor in
                subscriptions.removeAll()
                try await actionHandler.setObjectSetType()
                router.replaceCurrentPage(with: .set(.init(objectId: document.objectId, spaceId: document.spaceId)))
            }
            return
        }
        
        if type.isCollectionType {
            Task { @MainActor in
                subscriptions.removeAll()
                try await actionHandler.setObjectCollectionType()
                router.replaceCurrentPage(with: .set(.init(objectId: document.objectId, spaceId: document.spaceId)))
            }
            return
        }
        
        Task { @MainActor in
            try await actionHandler.setObjectType(type: type)
            try await actionHandler.applyTemplate(objectId: document.objectId, templateId: type.defaultTemplateId)
            // TODO: Paste content
        }
    }
    
    private func onChangeTypeToBookmark(url: String) {
        // TODO: Create bookmark
    }
}
