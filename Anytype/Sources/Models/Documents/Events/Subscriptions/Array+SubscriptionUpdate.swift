import BlocksModels
import AnytypeCore

protocol IdProvider {
    var id: BlockId { get }
}

extension ObjectDetails: IdProvider {}

extension Array where Element == ObjectDetails {
    mutating func applySubscriptionUpdate(_ update: SubscriptionUpdate) {
        applySubscriptionUpdate(update) { $0 }
    }
}

extension Array where Element: IdProvider {
    mutating func applySubscriptionUpdate(_ update: SubscriptionUpdate, transform: (ObjectDetails) -> (Element)) {
        switch update {
        case .initialData(let data):
            self = data.map { transform($0) }
        case .update(let data):
            let newData = transform(data)
            guard let index = indexInCollection(blockId: newData.id) else { return }
            self[index] = newData
        case .remove(let blockId):
            guard let index = indexInCollection(blockId: blockId) else { return }
            self.remove(at: index)
        case let .add(details, afterId):
            guard let index = indexInCollection(afterId: afterId) else { return }
            self.insert(transform(details), at: index)
        case let .move(from, after):
            guard let index = indexInCollection(blockId: from) else { break }
            guard let insertIndex = indexInCollection(afterId: after) else { break }
            self.moveElement(from: index, to: insertIndex)
        case .pageCount:
            break
        }
    }
    
    private func indexInCollection(afterId: BlockId?) -> Int? {
        guard let afterId = afterId else { return 0 }
        guard let index = indexInCollection(blockId: afterId) else { return nil }
        
        return index + 1
    }

    private func indexInCollection(blockId: BlockId) -> Int? {
        guard let index = firstIndex(where: { $0.id == blockId }) else {
            return nil
        }
        
        return index
    }
}
