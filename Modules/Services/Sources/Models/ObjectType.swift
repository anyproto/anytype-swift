import ProtobufMessages
import AnytypeCore

public enum ObjectTypeIcon: Equatable, Hashable, Codable, Identifiable, Sendable {
    case emoji(Emoji)
    case customIcon(CustomIcon, CustomIconColor)
    
    init?(icon: CustomIcon?, iconColor: CustomIconColor?, emoji: Emoji?) {
        if let icon {
            self = .customIcon(icon, iconColor ?? CustomIconColor.default)
        } else if let emoji {
            self = .emoji(emoji)
        }

        return nil
    }
    
    public var id: String {
        switch self {
        case .emoji(let emoji):
            emoji.id
        case .customIcon(let customIcon, let customIconColor):
            "\(customIcon.id)-\(customIconColor.id)"
        }
    }
}

public struct ObjectType: Equatable, Hashable, Codable, Identifiable, Sendable {
    
    public let id: String
    public let name: String
    public let typeIcon: ObjectTypeIcon?
    public let description: String
    public let hidden: Bool
    public let readonly: Bool
    public let isArchived: Bool
    public let isDeleted: Bool
    public let sourceObject: String
    public let spaceId: String
    public let uniqueKey: ObjectTypeUniqueKey
    public let defaultTemplateId: String
    public let canCreateObjectOfThisType: Bool
    
    public let recommendedRelations: [ObjectId]
    public let recommendedLayout: DetailsLayout?
    
    public init(
        id: String,
        name: String,
        typeIcon: ObjectTypeIcon?,
        description: String,
        hidden: Bool,
        readonly: Bool,
        isArchived: Bool,
        isDeleted: Bool,
        sourceObject: String,
        spaceId: String,
        uniqueKey: ObjectTypeUniqueKey,
        defaultTemplateId: String,
        canCreateObjectOfThisType: Bool,
        recommendedRelations: [ObjectId],
        recommendedLayout: DetailsLayout?
    ) {
        self.id = id
        self.name = name
        self.typeIcon = typeIcon
        self.description = description
        self.hidden = hidden
        self.readonly = readonly
        self.isArchived = isArchived
        self.isDeleted = isDeleted
        self.sourceObject = sourceObject
        self.spaceId = spaceId
        self.uniqueKey = uniqueKey
        self.defaultTemplateId = defaultTemplateId
        self.canCreateObjectOfThisType = canCreateObjectOfThisType
        self.recommendedRelations = recommendedRelations
        self.recommendedLayout = recommendedLayout
    }
}

extension ObjectType: DetailsModel {
    
    public init(details: ObjectDetails) {
        self.init(
            id: details.id,
            name: details.name,
            typeIcon: ObjectTypeIcon(icon: details.customIcon, iconColor: details.customIconColor, emoji: details.iconEmoji),
            description: details.description,
            hidden: details.isHidden,
            readonly: details.isReadonly,
            isArchived: details.isArchived,
            isDeleted: details.isDeleted,
            sourceObject: details.sourceObject,
            spaceId: details.spaceId,
            uniqueKey: details.uniqueKeyValue,
            defaultTemplateId: details.defaultTemplateId,
            canCreateObjectOfThisType: !details.restrictionsValue.contains(.createObjectOfThisType),
            recommendedRelations: details.recommendedRelations,
            recommendedLayout: details.recommendedLayoutValue
        )
    }
    
    public static var subscriptionKeys: [BundledRelationKey] {
        return [
            BundledRelationKey.id,
            BundledRelationKey.name,
            BundledRelationKey.iconEmoji,
            BundledRelationKey.description,
            BundledRelationKey.isHidden,
            BundledRelationKey.isReadonly,
            BundledRelationKey.isArchived,
            BundledRelationKey.smartblockTypes,
            BundledRelationKey.sourceObject,
            BundledRelationKey.recommendedRelations,
            BundledRelationKey.recommendedLayout,
            BundledRelationKey.uniqueKey,
            BundledRelationKey.spaceId,
            BundledRelationKey.defaultTemplateId,
            BundledRelationKey.restrictions
        ]
    }
    
    public var isTemplateType: Bool { uniqueKey == .template }
    
    public var isDateType: Bool { uniqueKey == .date }
    
    // MARK: - Layout proxy
    public var isListType: Bool { recommendedLayout.isList }
    
    public var isSetType: Bool { recommendedLayout.isSet }
    
    public var isCollectionType: Bool { recommendedLayout.isCollection }
    
    public var isNoteLayout: Bool { recommendedLayout.isNote }
    
    public var isImageLayout: Bool { recommendedLayout.isImage }
}
