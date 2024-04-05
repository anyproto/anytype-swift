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
    
    var objectIconImage: Icon? {
        return objectIcon.map { .object($0) }
    }
    
    var objectIconImageWithPlaceholder: Icon {
        return objectIconImage ?? .object(.placeholder(title))
    }
    
    var objectType: ObjectType {
        let parsedType = try? ObjectTypeProvider.shared.objectType(id: type)
        return parsedType ?? ObjectTypeProvider.shared.deletedObjectType(id: type)
    }
    
    var editorViewType: EditorViewType {
        switch layoutValue {
        case .basic, .profile, .participant, .todo, .note, .bookmark, .space, .file, .image, .objectType, .UNRECOGNIZED, .relation,
                .relationOption, .dashboard, .relationOptionsList, .pdf, .audio, .video, .date, .spaceView:
            return .page
        case .set, .collection:
            return .set
        }
    }
    
    var isList: Bool {
        isSet || isCollection
    }
    
    var isCollection: Bool {
        return layoutValue == .collection
    }
    
    var isSet: Bool {
        return layoutValue == .set
    }
    
    var isSupportedForEdit: Bool {
        return DetailsLayout.supportedForEditLayouts.contains(layoutValue)
    }
    
    var isVisibleLayout: Bool {
        return DetailsLayout.visibleLayouts.contains(layoutValue)
    }
    
    var isNotDeletedAndVisibleForEdit: Bool {
        return !isDeleted && !isArchived && isVisibleLayout && !isHiddenDiscovery
    }
    
    var isNotDeletedAndSupportedForEdit: Bool {
        return !isDeleted && !isArchived && isSupportedForEdit && !isHiddenDiscovery
    }
    
    var canMakeTemplate: Bool {
        layoutValue.isTemplatesAvailable && !isTemplateType && profileOwnerIdentity.isEmpty
    }
    
    var isTemplateType: Bool {
        objectType.isTemplateType
    }
}
