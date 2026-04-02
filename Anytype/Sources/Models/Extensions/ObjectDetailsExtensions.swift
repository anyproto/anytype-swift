import Services
import UIKit
import AnytypeCore

extension BundledPropertiesValueProvider {
    
    // MARK: - Cover
    
    var documentCover: DocumentCover? {
        guard !coverId.isEmpty else { return nil }
        
        switch coverTypeValue {
        case .none:
            return nil
        case .uploadedImage:
            return DocumentCover.imageId(coverId)
        case .color:
            return CoverColor.allCases
                .first { $0.data.name == coverId }
                .flatMap { .color($0.uiColor) }
        case .gradient:
            return CoverGradient.allCases
                .first { $0.data.name == coverId }
                .flatMap { .gradient($0.gradientColor) }
        case .unsplash:
            return DocumentCover.imageId(coverId)
        }
    }
    
    var objectIconImage: Icon {
        if let objectIcon = objectIcon.map({ Icon.object($0) }) {
            return objectIcon
        }
        
        if let typeIcon = objectType.icon.customIcon {
            return .object(.customIcon(CustomIconData(placeholderIcon: typeIcon)))
        }
        
        return .object(.defaultObjectIcon)
    }
    
    var objectAlignValue: LayoutAlignment {
        if isObjectType {
            layoutAlignValue
        } else if isTemplate, let targetObjectTypeValue = targetObjectTypeValue {
            targetObjectTypeValue.layoutAlign
        } else {
            objectType.layoutAlign
        }
    }
    
    var objectType: ObjectType {
        let parsedType = try? ObjectTypeProvider.shared.objectType(id: type)
        return parsedType ?? ObjectTypeProvider.shared.deletedObjectType(id: type)
    }
    
    var targetObjectTypeValue: ObjectType? {
        return try? ObjectTypeProvider.shared.objectType(id: targetObjectType)
    }
    
    var editorViewType: ScreenType {
        switch resolvedLayoutValue {
        case .basic, .profile, .todo, .note, .space, .UNRECOGNIZED, .relation,
                .relationOption, .dashboard, .relationOptionsList, .spaceView,
                .tag, .notification, .missingObject, .devices:
            return .page
        case .set, .collection:
            return .list
        case .date:
            return .date
        case .objectType:
            return .type
        case .participant:
            return .participant
        case .image, .video, .audio, .file, .pdf:
            return .mediaFile
        case .bookmark:
            return .bookmark
        case .chatDeprecated, .chatDerived:
            return .chat
        case .discussion:
            return .discussion
        }
    }
    
    var filteredSetOf: [String] {
        setOf.filter { $0.isNotEmpty }
    }
    
    var isNotDeletedAndSupportedForOpening: Bool {
        return !isDeleted && !isArchived && isSupportedForOpening && !isHiddenDiscovery
    }
    
    var isNotDeletedAndArchived: Bool {
        return !isDeleted && !isArchived
    }

    var isArchivedOrDeleted: Bool {
        return isArchived || isDeleted
    }
    
    var isTemplate: Bool { objectType.isTemplateType }

    var isTemplateNamePrefilled: Bool {
        (templateNamePrefillType ?? 0) != 0
    }

    var isTemplateType: Bool { uniqueKey == ObjectTypeUniqueKey.template.value }
    
    var canMakeTemplate: Bool {
        resolvedLayoutValue.isEditorLayout && !isTemplate && profileOwnerIdentity.isEmpty && !isObjectType
    }
    
    // Properties
    var recommendedRelationsDetails: [PropertyDetails] {
        Container.shared.propertyDetailsStorage().relationsDetails(ids: recommendedRelations, spaceId: spaceId)
    }
    var recommendedFeaturedRelationsDetails: [PropertyDetails] {
        Container.shared.propertyDetailsStorage().relationsDetails(ids: recommendedFeaturedRelations, spaceId: spaceId)
    }

    var recommendedHiddenRelationsDetails: [PropertyDetails] {
        Container.shared.propertyDetailsStorage().relationsDetails(ids: recommendedHiddenRelations, spaceId: spaceId)
    }
    
    // MARK: - DetailsLayout proxy
    
    var isList: Bool { resolvedLayoutValue.isList }
    
    var isCollection: Bool { resolvedLayoutValue.isCollection }
    
    var isSet: Bool { resolvedLayoutValue.isSet }
    
    var isObjectType: Bool { resolvedLayoutValue.isObjectType }
    
    var isSupportedForOpening: Bool { resolvedLayoutValue.isSupportedForOpening }

    @available(*, deprecated, message: "Use spaceType overload instead")
    func isVisibleLayout(spaceUxType: SpaceUxType?) -> Bool {
        DetailsLayout.visibleLayouts(spaceUxType: spaceUxType).contains(resolvedLayoutValue)
    }

    func isVisibleLayout(spaceType: SpaceType?) -> Bool {
        DetailsLayout.visibleLayouts(spaceType: spaceType).contains(resolvedLayoutValue)
    }

    var displayName: String {
         return globalName.isNotEmpty ? globalName : identity
     }
}

extension ObjectDetails {
    var previewRemoteItem: PreviewRemoteItem {        
        let fileDetails = FileDetails(objectDetails: self)
        return fileDetails.previewRemoteItem
    }
}

extension FileDetails {
    var previewRemoteItem: PreviewRemoteItem  {
        switch fileContentType {
        case .image:
            return PreviewRemoteItem(fileDetails: self, type: .image())
        case .file, .audio, .video, .none:
            return PreviewRemoteItem(fileDetails: self, type: .file)
        }
    }
}
