import Foundation
import BlocksModels

extension Relation {
    var isBundled: Bool {
        guard let keyType = BundledRelationKey(rawValue: key) else { return false }
        return BundledRelationKey.readonlyKeys.contains(keyType)
    }
}
