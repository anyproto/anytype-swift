import BlocksModels
import AnytypeCore

extension Array where Element == HomeCellData {
    mutating func applySubscriptionUpdate(_ update: SubscriptionUpdate, builder: HomeCellDataBuilder) {
        switch update {
        case .initialData(let data):
            self = builder.buildCellData(data)
        case .update(let data):
            let newData = builder.buildCellData(data)
            guard let index = indexInCollection(blockId: newData.id, assert: false) else { return }
            self[index] = newData
        case .remove(let blockId):
            guard let index = indexInCollection(blockId: blockId) else { return }
            self.remove(at: index)
        case let .add(details, afterId):
            guard let index = indexInCollection(afterId: afterId) else { return }
            let newData = builder.buildCellData(details)
            self.insert(newData, at: index)
        case let .move(from, after):
            guard let index = indexInCollection(blockId: from) else { break }
            guard let insertIndex = indexInCollection(afterId: after) else { break }
            self.moveElement(from: index, to: insertIndex)
        }
    }
    
    private func indexInCollection(afterId: BlockId?) -> Int? {
        guard let afterId = afterId else { return 0 }
        guard let index = indexInCollection(blockId: afterId) else { return nil }
        
        return index + 1
    }

    private func indexInCollection(blockId: BlockId, assert: Bool = true) -> Int? {
        guard let index = self.firstIndex(where: { $0.id == blockId }) else {
            if assert {
                anytypeAssertionFailure("No history cell found for blockId: \(blockId)", domain: .homeView)
            }
            return nil
        }
        
        return index
    }
}
