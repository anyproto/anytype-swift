import Services

extension EditorPageViewModel {
    func onChangeType(type: ObjectType) {
        if type.recommendedLayout == .set {
            Task { @MainActor in
                subscriptions.removeAll()
                try await actionHandler.setObjectSetType()
                router.replaceCurrentPage(with: .set(.init(objectId: document.objectId, spaceId: document.spaceId)))
            }
            return
        }
        
        if type.recommendedLayout == .collection {
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
