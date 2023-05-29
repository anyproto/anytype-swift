import Foundation
import BlocksModels

extension RelationDetails {
    var isSystem: Bool {
        guard let keyType = BundledRelationKey(rawValue: key) else { return false }
        return BundledRelationKey.systemKeys.contains(keyType)
    }
}
