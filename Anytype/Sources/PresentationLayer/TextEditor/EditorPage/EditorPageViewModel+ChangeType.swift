import Services
import AnytypeCore


extension EditorPageViewModel {
    func onChangeType(typeSelection: TypeSelectionResult) async throws {
        switch typeSelection {
        case .objectType(let type):
            onChangeType(type: type)
        case .createFromPasteboard:
            switch PasteboardHelper().pasteboardContent {
            case .none:
                anytypeAssertionFailure("Empty clipboard")
                return
            case .url(let url):
                try await actionHandler.turnIntoBookmark(url: url)
            case .string:
                fallthrough
            case .otherContent:
                let type = try objectTypeProvider.defaultObjectType(spaceId: document.spaceId)
                try await actionHandler.applyTemplate(objectId: document.objectId, templateId: type.defaultTemplateId)
                actionHandler.pasteContent()
            }
        }
    }
    
    private func onChangeType(type: ObjectType) {
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
        }
    }
}
