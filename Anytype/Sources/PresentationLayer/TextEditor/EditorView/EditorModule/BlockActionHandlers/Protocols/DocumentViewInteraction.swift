import BlocksModels

protocol DocumentViewInteraction: AnyObject {
    /// Update blocks by ids
    /// - Parameter ids: blocks ids
    func updateBlocks(with ids: Set<BlockId>)
    
    func findModel(beforeBlockId blockId: BlockId) -> BlockActiveRecordProtocol?
}


extension DocumentEditorViewModel: DocumentViewInteraction {
    func findModel(beforeBlockId blockId: BlockId) -> BlockActiveRecordProtocol? {
        guard let modelIndex = blocksViewModels.firstIndex(where: { $0.block.blockId == blockId }) else {
            return nil
            
        }

        let index = blocksViewModels.index(before: modelIndex)
        guard index >= blocksViewModels.startIndex else {
            return nil
        }
        
        return blocksViewModels[index].block
    }
    
    func updateBlocks(with ids: Set<BlockId>) {
        updateElementsSubject.send(ids)
    }
}
