import Foundation
import Services

extension RelationDetails {
    var canBeRemovedFromObject: Bool {
        guard let keyType = BundledRelationKey(rawValue: key) else { return true }
        return !BundledRelationKey.internalKeys.contains(keyType) && !isHidden && !isReadOnlyValue
    }
}
