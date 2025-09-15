import ProtobufMessages
import AnytypeCore
import Foundation


public struct ObjectType: Equatable, Hashable, Codable, Identifiable, Sendable {
    
    public let id: String
    public let name: String
    public let pluralName: String
    public let icon: ObjectIcon
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
    public let isDeletable: Bool
    public let layoutAlign: LayoutAlignment
    public let layoutWidth: Int?
    
    public let recommendedRelations: [ObjectId]
    public let recommendedFeaturedRelations: [ObjectId]
    public let recommendedHiddenRelations: [ObjectId]
    public let recommendedLayout: DetailsLayout?
    
    public let lastUsedDate: Date?
    
    public let orderId: String
    
    public init(
        id: String,
        name: String,
        pluralName: String,
        icon: ObjectIcon,
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
        isDeletable: Bool,
        layoutAlign: LayoutAlignment,
        layoutWidth: Int?,
        recommendedRelations: [ObjectId],
        recommendedFeaturedRelations: [ObjectId],
        recommendedHiddenRelations: [ObjectId],
        recommendedLayout: DetailsLayout?,
        lastUsedDate: Date?,
        orderId: String
    ) {
        self.id = id
        self.name = name
        self.pluralName = pluralName
        self.icon = icon
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
        self.isDeletable = isDeletable
        self.layoutAlign = layoutAlign
        self.layoutWidth = layoutWidth
        self.recommendedRelations = recommendedRelations
        self.recommendedFeaturedRelations = recommendedFeaturedRelations
        self.recommendedHiddenRelations = recommendedHiddenRelations
        self.recommendedLayout = recommendedLayout
        self.lastUsedDate = lastUsedDate
        self.orderId = orderId
    }
}

extension ObjectType: DetailsModel {
    
    public init(details: ObjectDetails) {
        self.init(
            id: details.id,
            name: details.name,
            pluralName: details.pluralName,
            icon: details.objectIcon ?? .emptyTypeIcon,
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
            isDeletable: !details.restrictionsValue.contains(.delete),
            layoutAlign: details.layoutAlignValue,
            layoutWidth: details.layoutWidth,
            recommendedRelations: details.recommendedRelations,
            recommendedFeaturedRelations: details.recommendedFeaturedRelations,
            recommendedHiddenRelations: details.recommendedHiddenRelations,
            recommendedLayout: details.recommendedLayoutValue,
            lastUsedDate: details.lastUsedDate,
            orderId: details.orderId
        )
    }
    
    public static var subscriptionKeys: [BundledPropertyKey] {
        return [
            BundledPropertyKey.id,
            BundledPropertyKey.name,
            BundledPropertyKey.pluralName,
            BundledPropertyKey.iconEmoji,
            BundledPropertyKey.iconName,
            BundledPropertyKey.iconImage,
            BundledPropertyKey.iconOption,
            BundledPropertyKey.description,
            BundledPropertyKey.isHidden,
            BundledPropertyKey.isReadonly,
            BundledPropertyKey.isArchived,
            BundledPropertyKey.smartblockTypes,
            BundledPropertyKey.sourceObject,
            BundledPropertyKey.recommendedRelations,
            BundledPropertyKey.recommendedFeaturedRelations,
            BundledPropertyKey.recommendedHiddenRelations,
            BundledPropertyKey.recommendedLayout,
            BundledPropertyKey.uniqueKey,
            BundledPropertyKey.spaceId,
            BundledPropertyKey.defaultTemplateId,
            BundledPropertyKey.restrictions,
            BundledPropertyKey.resolvedLayout,
            BundledPropertyKey.layoutAlign,
            BundledPropertyKey.layoutWidth,
            BundledPropertyKey.type,
            BundledPropertyKey.lastUsedDate,
            BundledPropertyKey.orderId
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
