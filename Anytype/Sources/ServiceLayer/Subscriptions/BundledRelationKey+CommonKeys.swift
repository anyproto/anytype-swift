import Foundation
import BlocksModels

extension BundledRelationKey {
    
    // Keys for calculated properties
    
    static var titleKeys: [BundledRelationKey] {
        return [
            .isDeleted,
            .snippet,
            .name,
            .fileExt
        ]
    }
    
    static var iconKeys: [BundledRelationKey] {
        return .builder {
            BundledRelationKey.layout
            BundledRelationKey.iconImage
            BundledRelationKey.iconEmoji
            BundledRelationKey.titleKeys
            BundledRelationKey.iconOption
        }.uniqued()
    }
    
    static var objectIconImageKeys: [BundledRelationKey] {
        return .builder {
            BundledRelationKey.isDeleted
            BundledRelationKey.layout
            BundledRelationKey.done
            BundledRelationKey.iconKeys
            BundledRelationKey.fileMimeType
            BundledRelationKey.name
        }.uniqued()
    }
    
    // Keys for object list screens
    
    static var objectListKeys: [BundledRelationKey] {
        return .builder {
            BundledRelationKey.id
            BundledRelationKey.description
            BundledRelationKey.type
            BundledRelationKey.isArchived
            BundledRelationKey.isDeleted
            BundledRelationKey.isFavorite
            // Complex keys
            BundledRelationKey.objectIconImageKeys
            BundledRelationKey.titleKeys
        }.uniqued()
    }
}
