import BlocksModels

// We need to share models between several mutating services
// Using reference semantics of SharedBlockViewModelsHolder to share pointer
// To the same models everywhere
final class SharedBlockViewModelsHolder {
    var models: [BaseBlockViewModel] = []

    func findModel(beforeBlockId blockId: BlockId) -> BlockActiveRecordProtocol? {
        guard let modelIndex = models.firstIndex(where: { $0.block.blockId == blockId }) else {
            return nil
            
        }

        let index = models.index(before: modelIndex)
        guard index >= models.startIndex else {
            return nil
        }
        
        return models[index].block
    }
}
