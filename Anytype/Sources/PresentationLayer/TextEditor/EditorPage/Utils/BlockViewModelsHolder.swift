import BlocksModels

// We need to share models between several mutating services
// Using reference semantics of BlockViewModelsHolder to share pointer
// To the same models everywhere
final class BlockViewModelsHolder {
    
    let objectId: String
    
    var models: [BlockViewModelProtocol] = []

    init(objectId: String) {
        self.objectId = objectId
    }
    
    func findModel(beforeBlockId blockId: BlockId, skipFeaturedRelations: Bool = true) -> BlockDataProvider? {
        guard let modelIndex = models.firstIndex(where: { $0.blockId == blockId }) else {
            return nil
        }

        let index = models.index(before: modelIndex)
        guard let model = models[safe: index] else {
            return nil
        }
        
        if model.content.type == .featuredRelations && skipFeaturedRelations {
            return self.findModel(beforeBlockId: model.blockId)
        }
    
        return model
    }
}

extension BlockViewModelsHolder {
    
    func apply(newModels: [BlockViewModelProtocol]) {
        let difference = newModels.difference(
            from: models
        ) { $0.hashable == $1.hashable }
        
        
        if !difference.isEmpty, let result = models.applying(difference) {
            models = result
        }
    }
    
}
