import UIKit

enum SlashMenuItemType {
    case style
    case media
    case objects
    case relations
    case other
    case actions
    case color
    case background
    case alignment
    
    var title: String {
        switch self {
        case .style:
            return "Style".localized
        case .media:
            return "Media".localized
        case .objects:
            return "Objects".localized
        case .relations:
            return "Relations".localized
        case .other:
            return "Other".localized
        case .actions:
            return "Actions".localized
        case .color:
            return "Color".localized
        case .background:
            return "Background".localized
        case .alignment:
            return "Alignment".localized
        }
    }
    
    var iconName: ObjectIconImage {
        switch self {
        case .style:
            return .staticImage(ImageName.slashMenu.groups.style)
        case .media:
            return .staticImage(ImageName.slashMenu.groups.media)
        case .objects:
            return .staticImage(ImageName.slashMenu.groups.objects)
        case .relations:
            return .staticImage(ImageName.slashMenu.groups.relation)
        case .other:
            return .staticImage(ImageName.slashMenu.groups.other)
        case .actions:
            return .staticImage(ImageName.slashMenu.groups.actions)
        case .color:
            let image = UIImage.circleImage(
                size: .init(width: 22, height: 22),
                fillColor: .textPrimary,
                borderColor: .clear,
                borderWidth: 0
            )
            return .image(image)
        case .background:
            let image = UIImage.circleImage(
                size: .init(width: 22, height: 22),
                fillColor: .backgroundPrimary,
                borderColor: .strokePrimary,
                borderWidth: 0.5
            )
            return .image(image)
        case .alignment:
            return .staticImage(ImageName.slashMenu.groups.alignment)
        }
    }

    var displayData: SlashMenuItemDisplayData {
        SlashMenuItemDisplayData(iconData: iconName, title: self.title)
    }
}
