import Foundation
import Services

extension RelationDetails {
    var isSystem: Bool {
        guard let keyType = BundledRelationKey(rawValue: key) else { return false }
        return BundledRelationKey.systemKeys.contains(keyType)
    }
}
