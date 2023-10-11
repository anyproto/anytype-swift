import Services
import AnytypeCore

extension Array where Element == BlockId {
    mutating func applySubscriptionUpdate(_ update: SubscriptionUpdate) {
        switch update {
        case let  .remove(blockId):
            guard let index = indexInCollection(blockId: blockId) else { return }
            self.remove(at: index)
        case let .add(blockId, afterId):
            guard let index = indexInCollection(afterId: afterId) else { return }
            self.insert(blockId, at: index)
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

    private func indexInCollection(blockId: BlockId) -> Int? {
        guard let index = firstIndex(where: { $0 == blockId }) else {
            return nil
        }
        
        return index
    }
}
