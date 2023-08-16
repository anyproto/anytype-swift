import Foundation
import AnytypeCore
import ProtobufMessages

public extension BundledRelationKey {
    static var sortIncudeTimeKeys: [BundledRelationKey] = [
        .lastOpenedDate,
        .lastModifiedDate,
        .createdDate
    ]
}

// MARK: - Helpers

public extension DataviewSort {
    func fixIncludeTime() -> Self {
        let rawKeys = BundledRelationKey.sortIncudeTimeKeys.map(\.rawValue)
        
        if rawKeys.contains(relationKey) {
            var newSort = self
            newSort.includeTime = true
            return newSort
        }
        
        return self
    }
}
