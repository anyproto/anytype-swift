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
        return objectIcon.map { .object($0) } ?? .object(.empty(emptyIconType))
    }
    
    var objectType: ObjectType {
        let parsedType = try? ObjectTypeProvider.shared.objectType(id: type)
        return parsedType ?? ObjectTypeProvider.shared.deletedObjectType(id: type)
    }
    
    var editorViewType: ScreenType {
        switch layoutValue {
        case .basic, .profile, .todo, .note, .space, .UNRECOGNIZED, .relation,
                .relationOption, .dashboard, .relationOptionsList, .spaceView, .tag, .chat, .chatDerived:
            return .page
        case .set, .collection:
            return .list
        case .date:
            return .date
        case .objectType:
            return .type
        case .participant:
            return FeatureFlags.memberProfile ? .participant : .page
        case .image, .video, .audio, .file, .pdf:
            return FeatureFlags.openMediaFileInPreview ? .mediaFile : .page
        case .bookmark:
            return FeatureFlags.openBookmarkAsLink ? .bookmark : .page
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
        layoutValue.isEditorLayout && !isTemplateType && profileOwnerIdentity.isEmpty
    }
    
    // MARK: - DetailsLayout proxy
    
    var isList: Bool { layoutValue.isList }
    
    var isCollection: Bool { layoutValue.isCollection }
    
    var isSet: Bool { layoutValue.isSet }
    
    var isObjectType: Bool { layoutValue.isObjectType }
    
    var isSupportedForOpening: Bool { layoutValue.isSupportedForOpening }
    
    var isVisibleLayout: Bool { layoutValue.isVisible }
    
    private var emptyIconType: ObjectIcon.EmptyType {
        switch layoutValue {
        case .basic, .profile, .participant, .todo, .note, .space, .file, .image, .UNRECOGNIZED, .relation,
                .relationOption, .dashboard, .relationOptionsList, .pdf, .audio, .video, .spaceView:
            return .page
        case .set, .collection:
            return .list
        case .bookmark:
            return .bookmark
        case .chat, .chatDerived:
            return .chat
        case .objectType:
            return .objectType
        case .tag:
            return .tag
        case .date:
            return .date
        }
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
