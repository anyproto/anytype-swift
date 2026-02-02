import Foundation
import AnytypeCore
import ProtobufMessages

public extension BundledPropertyKey {
    static let dateKeys: [BundledPropertyKey] = [
        .createdDate,
        .lastModifiedDate,
        .lastOpenedDate,
        .lastMessageDate,
        .dueDate,
        .addedDate,
        .lastUsedDate,
        .syncDate,
        .spaceJoinDate,
        .toBeDeletedDate
    ]
}

// MARK: - Helpers

public extension DataviewSort {
    func fixIncludeTime() -> Self {
        let rawKeys = BundledPropertyKey.dateKeys.map(\.rawValue)

        if rawKeys.contains(relationKey) {
            var newSort = self
            newSort.includeTime = true
            return newSort
        }

        return self
    }
}
