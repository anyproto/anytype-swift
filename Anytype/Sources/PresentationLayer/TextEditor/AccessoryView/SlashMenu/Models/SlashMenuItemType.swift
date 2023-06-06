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
            return .imageAsset(.X40.style)
        case .media:
            return .imageAsset(.X40.media)
        case .objects:
            return .imageAsset(.X40.objects)
        case .relations:
            return .imageAsset(.X40.relations)
        case .other:
            return .imageAsset(.X40.other)
        case .actions:
            return .imageAsset(.X40.actions)
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
            return .imageAsset(.X32.Align.left)
        }
    }

    var displayData: SlashMenuItemDisplayData {
        SlashMenuItemDisplayData(iconData: iconName, title: self.title)
    }
}
