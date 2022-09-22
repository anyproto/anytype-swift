import BlocksModels
import UIKit
import AnytypeCore

extension BundledRelationsValueProvider {
    
    // MARK: - Icon
    
    var icon: ObjectIconType? {
        switch layoutValue {
        case .basic, .set:
            return basicIcon
        case .profile:
            return profileIcon.flatMap { ObjectIconType.profile($0) }
        case .bookmark:
            return bookmarkIcon
        case .todo, .note:
            return nil
        }
    }
    
    private var basicIcon: ObjectIconType? {
        if let iconImageHash = self.iconImage {
            return ObjectIconType.basic(iconImageHash.value)
        }
        
        if let iconEmoji = self.iconEmoji {
            return ObjectIconType.emoji(iconEmoji)
        }
        
        return nil
    }
    
    private var profileIcon: ObjectIconType.Profile? {
        if let iconImageHash = self.iconImage {
            return ObjectIconType.Profile.imageId(iconImageHash.value)
        }
        
        return title.first.flatMap { ObjectIconType.Profile.character($0) }
    }
    
    private var bookmarkIcon: ObjectIconType? {
        return iconImage.map { ObjectIconType.bookmark($0.value) }
    }
    
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
    
    var objectIconImage: ObjectIconImage? {
        guard !isDeleted else {
            return ObjectIconImage.imageAsset(.ghost)
        }
        
        if let icon = icon {
            return .icon(icon)
        }
        
        if layoutValue == .todo {
            return .todo(isDone)
        }
        
        return nil
    }
    
    var objectType: ObjectType {
        guard !isDeleted, type.isNotEmpty else {
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
        switch layoutValue {
        case .basic, .profile, .todo, .note, .bookmark:
            return .page
        case .set:
            return .set
        }
    }
}
