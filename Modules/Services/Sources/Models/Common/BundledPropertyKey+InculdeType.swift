import Foundation
import AnytypeCore
import ProtobufMessages

public extension BundledPropertyKey {
    static let sortIncudeTimeKeys: [BundledPropertyKey] = [
        .lastOpenedDate,
        .lastModifiedDate,
        .createdDate
    ]
}

// MARK: - Helpers

public extension DataviewSort {
    func fixIncludeTime() -> Self {
        let rawKeys = BundledPropertyKey.sortIncudeTimeKeys.map(\.rawValue)
        
        if rawKeys.contains(relationKey) {
            var newSort = self
            newSort.includeTime = true
            return newSort
        }
        
        return self
    }
}
