import Foundation
import BlocksModels

extension RelationDetails {
    var isBundled: Bool {
        guard let keyType = BundledRelationKey(rawValue: key) else { return false }
        return BundledRelationKey.readonlyKeys.contains(keyType)
    }
}
