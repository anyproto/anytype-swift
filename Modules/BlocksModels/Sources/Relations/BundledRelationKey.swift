import Foundation

#warning("Rename to relation key")
public enum BundledRelationKey: String {
    
    case id
    case name
    case snippet
    case iconEmoji
    case iconImage
    case coverId
    case coverScale
    case coverType
    case coverX
    case coverY
    case isFavorite
    case description
    case layout
    case layoutAlign
    case done
    case type
    case targetObjectType
    case creator
    case createdDate
    case lastOpenedDate
    case lastModifiedBy
    case lastModifiedDate
    case addedDate
    case featuredRelations
    case internalFlags
    case url
    case picture
    case smartblockTypes
    
    case isDeleted
    case isArchived
    case isHidden
    case isReadonly
    case isHighlighted
    
    case workspaceId
    case fileExt
    case fileMimeType
    
    case relationOptionText
    case relationOptionColor
    case relationKey
    case relationFormat
    case readonlyValue
    case relationFormatObjectTypes
    case objectTypes
}


public extension BundledRelationKey {
    static var notRemovableRelationKeys: [BundledRelationKey] {
        [
            .id,
            .name,
            .description,
            .iconEmoji,
            .iconImage,
            .creator,
            .createdDate,
            .type,
            .layout,
            .layoutAlign,
            .lastOpenedDate,
            .lastModifiedBy,
            .lastModifiedDate,
            .addedDate,
            .coverId,
            .coverScale,
            .coverType,
            .coverX,
            .coverY,
            .featuredRelations,
            .isHidden,
            .isArchived,
            .smartblockTypes
        ]
    }
}
