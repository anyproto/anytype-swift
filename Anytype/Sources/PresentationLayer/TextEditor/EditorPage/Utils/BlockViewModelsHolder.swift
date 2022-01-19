import BlocksModels

// We need to share models between several mutating services
// Using reference semantics of BlockViewModelsHolder to share pointer
// To the same models everywhere
final class BlockViewModelsHolder {
    
    let objectId: String
    
    var models: [BlockViewModelProtocol] = []
    var header: ObjectHeader?

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
    
    func difference(between newModels: [BlockViewModelProtocol]) -> CollectionDifference<BlockViewModelProtocol> {
        if models.isEmpty { return .init([])! }

        return newModels.difference(
            from: models
        ) { $0.hashable == $1.hashable }
    }

    func applyDifference(difference: CollectionDifference<BlockViewModelProtocol>) {
        if !difference.isEmpty, let result = models.applying(difference) {
            models = result
        }
    }
    
}
