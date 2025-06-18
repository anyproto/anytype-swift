import Foundation
import Services

extension RelationDetails {
    var canBeRemovedFromObject: Bool {
        guard let keyType = BundledPropertyKey(rawValue: key) else { return true }
        return !BundledPropertyKey.internalKeys.contains(keyType) && !isHidden && !isReadOnlyValue
    }
    
    var canBeRemovedFromType: Bool {
        guard let keyType = BundledPropertyKey(rawValue: key) else { return true }
        
        return ![BundledPropertyKey.name, BundledPropertyKey.description].contains(keyType)
    }
    
    var analyticsKey: AnalyticsRelationKey {
        sourceObject.isNotEmpty ? .system(key: sourceObject) : .custom
    }
}
