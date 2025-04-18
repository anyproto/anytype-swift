import Services
import UIKit
import AnytypeCore

extension BundledRelationsValueProvider {
    
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
    
    var objectType: ObjectType {
        let parsedType = try? ObjectTypeProvider.shared.objectType(id: type)
        return parsedType ?? ObjectTypeProvider.shared.deletedObjectType(id: type)
    }
    
    var editorViewType: ScreenType {
        switch resolvedLayoutValue {
        case .basic, .profile, .todo, .note, .space, .UNRECOGNIZED, .relation,
                .relationOption, .dashboard, .relationOptionsList, .spaceView, .tag:
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
            return FeatureFlags.openMediaFileInPreview ? .mediaFile : .page
        case .bookmark:
            return FeatureFlags.openBookmarkAsLink ? .bookmark : .page
        case .chat, .chatDerived:
            return FeatureFlags.chatLayoutInsideSpace ? .chat : .page
        }
    }
    
    var filteredSetOf: [String] {
        setOf.filter { $0.isNotEmpty }
    }
    
    var isNotDeletedAndVisibleForEdit: Bool {
        return !isDeleted && !isArchived && isVisibleLayout && !isHiddenDiscovery
    }
    
    var isNotDeletedAndSupportedForOpening: Bool {
        return !isDeleted && !isArchived && isSupportedForOpening && !isHiddenDiscovery
    }
    
    var isNotDeletedAndArchived: Bool {
        return !isDeleted && !isArchived
    }
    
    var isTemplateType: Bool { objectType.isTemplateType }
    
    var canMakeTemplate: Bool {
        resolvedLayoutValue.isEditorLayout && !isTemplateType && profileOwnerIdentity.isEmpty && !isObjectType
    }
    
    // Properties
    var recommendedRelationsDetails: [RelationDetails] {
        Container.shared.relationDetailsStorage().relationsDetails(ids: recommendedRelations, spaceId: spaceId)
    }
    var recommendedFeaturedRelationsDetails: [RelationDetails] {
        Container.shared.relationDetailsStorage().relationsDetails(ids: recommendedFeaturedRelations, spaceId: spaceId)
    }

    var recommendedHiddenRelationsDetails: [RelationDetails] {
        Container.shared.relationDetailsStorage().relationsDetails(ids: recommendedHiddenRelations, spaceId: spaceId)
    }
    
    // MARK: - DetailsLayout proxy
    
    var isList: Bool { resolvedLayoutValue.isList }
    
    var isCollection: Bool { resolvedLayoutValue.isCollection }
    
    var isSet: Bool { resolvedLayoutValue.isSet }
    
    var isObjectType: Bool { resolvedLayoutValue.isObjectType }
    
    var isSupportedForOpening: Bool { resolvedLayoutValue.isSupportedForOpening }
    
    var isVisibleLayout: Bool { resolvedLayoutValue.isVisible }
    
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
