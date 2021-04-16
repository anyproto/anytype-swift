
import BlocksModels

final class TurnIntoSelectionStorage {
    
    private var storage = [BlockContentType: SelectionBucket]()
    private lazy var restrictionsFactory = BlockRestrictionsFactory()
    
    func deselectBlockType(type: BlockContentType) {
        guard var bucket = self.storage[type] else { return }
        bucket.count -= 1
        if bucket.count > 0 {
            self.storage[type] = bucket
        } else {
            self.storage.removeValue(forKey: type)
        }
    }
    
    func selectBlockType(type: BlockContentType) {
        if var bucket = self.storage[type] {
            bucket.count += 1
            self.storage[type] = bucket
        } else {
            let restrictions = self.restrictionsFactory.makeRestrictions(for: type)
            let bucket = SelectionBucket(count: 1, turnIntoOptions: Set(restrictions.turnIntoStyles))
            self.storage[type] = bucket
        }
    }
    
    func turnIntoOptions() -> [BlocksViews.Toolbar.BlocksTypes] {
        guard let initialResult = self.storage.first?.value.turnIntoOptions else { return [] }
        let turnIntoTypesIntersection = self.storage.values.reduce(into: initialResult) { result, bucket in
            result = result.intersection(bucket.turnIntoOptions)
        }
        return turnIntoTypesIntersection.sorted { $0 < $1 }
    }
    
    func clear() {
        self.storage.removeAll()
    }
}
