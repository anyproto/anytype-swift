import BlocksModels
import UIKit.UIColor

extension DetailsDataProtocol {
    
    // MARK: - Icon
    
    var icon: ObjectIconType? {
        guard let layout = self.layout else {
            return basicIcon
        }
        
        switch layout {
        case .basic:
            return basicIcon
        case .profile:
            return profileIcon.flatMap { ObjectIconType.profile($0) }
        case .todo:
            return nil
        }
    }
    
    private var basicIcon: ObjectIconType? {
        if let iconImageId = self.iconImage, !iconImageId.isEmpty {
            return ObjectIconType.basic(iconImageId)
        }
        
        if let iconEmoji = IconEmoji(self.iconEmoji) {
            return ObjectIconType.emoji(iconEmoji)
        }
        
        return nil
    }
    
    private var profileIcon: ObjectIconType.Profile? {
        if let iconImageId = self.iconImage, !iconImageId.isEmpty {
            return ObjectIconType.Profile.imageId(iconImageId)
        }
        
        return (self.name ?? "Untitled".localized).first.flatMap {
            ObjectIconType.Profile.character($0)
        }
    }
    
    // MARK: - Cover
    
    var documentCover: DocumentCover? {
        guard
            let coverType = coverType,
            let coverId = coverId, !coverId.isEmpty
        else { return nil }
        
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
        
        if let layout = layout, layout == .todo {
            return .todo(done ?? false)
        }
        
        return nil
    }
    
}
