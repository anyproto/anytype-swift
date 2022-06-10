import BlocksModels
import UIKit
import AnytypeCore

extension BundledRelationsValueProvider {
    
    // MARK: - Icon
    
    var icon: ObjectIconType? {
        switch layout {
        case .basic, .set:
            return basicIcon
        case .profile:
            return profileIcon.flatMap { ObjectIconType.profile($0) }
        case .todo, .note:
            return nil
        }
    }
    
    private var basicIcon: ObjectIconType? {
        if let iconImageHash = self.iconImageHash {
            return ObjectIconType.basic(iconImageHash.value)
        }
        
        if let iconEmoji = Emoji(self.iconEmoji) {
            return ObjectIconType.emoji(iconEmoji)
        }
        
        return nil
    }
    
    private var profileIcon: ObjectIconType.Profile? {
        if let iconImageHash = self.iconImageHash {
            return ObjectIconType.Profile.imageId(iconImageHash.value)
        }
        
        return title.first.flatMap { ObjectIconType.Profile.character($0) }
    }
    
    // MARK: - Cover
    
    var documentCover: DocumentCover? {
        guard !coverId.isEmpty else { return nil }
        
        switch coverType {
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
    
    var objectIconImage: ObjectIconImage? {
        guard !isDeleted else {
            return ObjectIconImage.staticImage(ImageName.ghost)
        }
        
        if let icon = icon {
            return .icon(icon)
        }
        
        if layout == .todo {
            return .todo(isDone)
        }
        
        return nil
    }
    
    var objectType: ObjectType {
        guard !isDeleted else {
            return ObjectTypeProvider.shared.defaultObjectType
        }
        
        let parsedType = ObjectTypeProvider.shared.objectType(url: type)
        anytypeAssert(
            parsedType != nil,
            "Cannot parse type :\(String(describing: type))",
            domain: .objectDetails
        )
        return parsedType ?? ObjectTypeProvider.shared.defaultObjectType
    }
    
    var editorViewType: EditorViewType {
        switch layout {
        case .basic, .profile, .todo, .note:
            return .page
        case .set:
            return .set
        }
    }
}
