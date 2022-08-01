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
            return Loc.style
        case .media:
            return Loc.media
        case .objects:
            return Loc.objects
        case .relations:
            return Loc.relations
        case .other:
            return Loc.other
        case .actions:
            return Loc.actions
        case .color:
            return Loc.color
        case .background:
            return Loc.background
        case .alignment:
            return Loc.alignment
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
