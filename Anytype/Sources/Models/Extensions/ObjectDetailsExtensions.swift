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
    
    var editorViewType: EditorViewType {
        switch layoutValue {
        case .basic, .profile, .participant, .todo, .note, .bookmark, .space, .file, .image, .UNRECOGNIZED, .relation,
                .relationOption, .dashboard, .relationOptionsList, .pdf, .audio, .video, .spaceView, .tag, .chat, .chatDerived:
            return .page
        case .set, .collection:
            return .list
        case .date:
            return FeatureFlags.dateAsAnObject ? .date : .page
        case .objectType:
            return .type
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
    
    var isTemplateType: Bool { objectType.isTemplateType }
    
    var canMakeTemplate: Bool {
        layoutValue.isEditorLayout && !isTemplateType && profileOwnerIdentity.isEmpty
    }
    
    // MARK: - DetailsLayout proxy
    
    var isList: Bool { layoutValue.isList }
    
    var isCollection: Bool { layoutValue.isCollection }
    
    var isSet: Bool { layoutValue.isSet }
    
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
