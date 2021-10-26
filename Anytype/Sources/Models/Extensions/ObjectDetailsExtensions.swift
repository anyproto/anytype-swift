import BlocksModels
import UIKit
import AnytypeCore

extension RelationValuesProtocol {
    
    // MARK: - Icon
    
    var icon: ObjectIconType? {
        switch layout {
        case .basic, .note:
            return basicIcon
        case .profile:
            return profileIcon.flatMap { ObjectIconType.profile($0) }
        case .todo:
            return nil
        }
    }
    
    private var basicIcon: ObjectIconType? {
        if let iconImageHash = self.iconImageHash {
            return ObjectIconType.basic(iconImageHash.value)
        }
        
        if let iconEmoji = IconEmoji(self.iconEmoji) {
            return ObjectIconType.emoji(iconEmoji)
        }
        
        return nil
    }
    
    private var profileIcon: ObjectIconType.Profile? {
        if let iconImageHash = self.iconImageHash {
            return ObjectIconType.Profile.imageId(iconImageHash.value)
        }
        
        return (self.name.isEmpty ? "Untitled".localized : self.name).first.flatMap {
            ObjectIconType.Profile.character($0)
        }
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
            return CoverConstants.colors.first { $0.name == coverId }.flatMap {
                DocumentCover.color(UIColor(hexString: $0.hex))
            }
        case .gradient:
            return CoverConstants.gradients.first { $0.name == coverId }.flatMap {
                DocumentCover.gradient(
                    GradientColor(
                        start: UIColor(hexString: $0.startHex),
                        end: UIColor(hexString: $0.endHex)
                    )
                )
            }
        }
    }
    
    var objectIconImage: ObjectIconImage? {
        if let icon = icon {
            return .icon(icon)
        }
        
        if layout == .todo {
            return .todo(isDone)
        }
        
        return nil
    }
    
    var objectType: ObjectType? {
        let type = ObjectTypeProvider.objectType(url: type)
        anytypeAssert(type != nil, "Cannot parse type :\(String(describing: type)))")
        return type
    }
    
}
