import Foundation

public extension BundledRelationKey {
    
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
            BundledRelationKey.resolvedLayout
            BundledRelationKey.iconImage
            BundledRelationKey.iconEmoji
            BundledRelationKey.iconName
            BundledRelationKey.titleKeys
            BundledRelationKey.iconOption
        }.uniqued()
    }
    
    static var objectIconImageKeys: [BundledRelationKey] {
        return .builder {
            BundledRelationKey.isDeleted
            BundledRelationKey.resolvedLayout
            BundledRelationKey.done
            BundledRelationKey.iconKeys
            BundledRelationKey.fileMimeType
            BundledRelationKey.name
        }.uniqued()
    }
    
    static var templatePreviewKeys: [BundledRelationKey] {
        .builder {
            BundledRelationKey.objectIconImageKeys
            BundledRelationKey.titleKeys
            BundledRelationKey.iconImage
            BundledRelationKey.iconEmoji
            BundledRelationKey.iconName
            BundledRelationKey.iconOption
            BundledRelationKey.coverId
            BundledRelationKey.coverType
            BundledRelationKey.id
            BundledRelationKey.layoutAlign
            BundledRelationKey.spaceId
        }.uniqued()
    }
    
    // Keys for object list screens
    
    static var objectListKeys: [BundledRelationKey] {
        return .builder {
            BundledRelationKey.id
            BundledRelationKey.spaceId
            BundledRelationKey.description
            BundledRelationKey.type
            BundledRelationKey.isArchived
            BundledRelationKey.isDeleted
            BundledRelationKey.isFavorite
            BundledRelationKey.restrictions
            // Complex keys
            BundledRelationKey.objectIconImageKeys
            BundledRelationKey.titleKeys
            // Open bookmark in whole app
            BundledRelationKey.source
        }.uniqued()
    }
}
