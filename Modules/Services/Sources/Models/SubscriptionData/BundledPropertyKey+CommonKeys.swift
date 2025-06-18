import Foundation

public extension BundledPropertyKey {
    
    // Keys for calculated properties
    
    static var titleKeys: [BundledPropertyKey] {
        return [
            .isDeleted,
            .snippet,
            .name,
            .fileExt
        ]
    }
    
    static var iconKeys: [BundledPropertyKey] {
        return .builder {
            BundledPropertyKey.resolvedLayout
            BundledPropertyKey.iconImage
            BundledPropertyKey.iconEmoji
            BundledPropertyKey.iconName
            BundledPropertyKey.titleKeys
            BundledPropertyKey.iconOption
        }.uniqued()
    }
    
    static var objectIconImageKeys: [BundledPropertyKey] {
        return .builder {
            BundledPropertyKey.isDeleted
            BundledPropertyKey.resolvedLayout
            BundledPropertyKey.done
            BundledPropertyKey.iconKeys
            BundledPropertyKey.fileMimeType
            BundledPropertyKey.name
            BundledPropertyKey.pluralName
        }.uniqued()
    }
    
    static var templatePreviewKeys: [BundledPropertyKey] {
        .builder {
            BundledPropertyKey.objectIconImageKeys
            BundledPropertyKey.titleKeys
            BundledPropertyKey.iconImage
            BundledPropertyKey.iconEmoji
            BundledPropertyKey.iconName
            BundledPropertyKey.iconOption
            BundledPropertyKey.coverId
            BundledPropertyKey.coverType
            BundledPropertyKey.id
            BundledPropertyKey.layoutAlign
            BundledPropertyKey.spaceId
        }.uniqued()
    }
    
    // Keys for object list screens
    
    static var objectListKeys: [BundledPropertyKey] {
        return .builder {
            BundledPropertyKey.id
            BundledPropertyKey.spaceId
            BundledPropertyKey.description
            BundledPropertyKey.type
            BundledPropertyKey.isArchived
            BundledPropertyKey.isDeleted
            BundledPropertyKey.isFavorite
            BundledPropertyKey.restrictions
            // Complex keys
            BundledPropertyKey.objectIconImageKeys
            BundledPropertyKey.titleKeys
            // Open bookmark in whole app
            BundledPropertyKey.source
            // Open Chat
            BundledPropertyKey.chatId
        }.uniqued()
    }
}
