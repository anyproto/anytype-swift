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
            return .imageAsset(.slashMenuGroupStyle)
        case .media:
            return .imageAsset(.slashMenuGroupMedia)
        case .objects:
            return .imageAsset(.slashMenuGroupObjects)
        case .relations:
            return .imageAsset(.slashMenuGroupRelation)
        case .other:
            return .imageAsset(.slashMenuGroupOther)
        case .actions:
            return .imageAsset(.slashMenuGroupActions)
        case .color:
            let image = UIImage.circleImage(
                size: .init(width: 22, height: 22),
                fillColor: .Text.primary,
                borderColor: .clear,
                borderWidth: 0
            )
            return .image(image)
        case .background:
            let image = UIImage.circleImage(
                size: .init(width: 22, height: 22),
                fillColor: .Background.primary,
                borderColor: .Stroke.primary,
                borderWidth: 0.5
            )
            return .image(image)
        case .alignment:
            return .imageAsset(.slashMenuAlignmentLeft)
        }
    }

    var displayData: SlashMenuItemDisplayData {
        SlashMenuItemDisplayData(iconData: iconName, title: self.title)
    }
}
