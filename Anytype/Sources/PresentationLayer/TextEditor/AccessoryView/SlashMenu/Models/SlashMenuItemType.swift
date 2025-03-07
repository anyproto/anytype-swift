import UIKit

enum SlashMenuItemType: Sendable {
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
            return Loc.fields
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
    
    var iconName: Icon {
        switch self {
        case .style:
            return .asset(.X40.style)
        case .media:
            return .asset(.X40.media)
        case .objects:
            return .asset(.X40.objects)
        case .relations:
            return .asset(.X40.relations)
        case .other:
            return .asset(.X40.other)
        case .actions:
            return .asset(.X40.actions)
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
                borderColor: .Shape.primary,
                borderWidth: 0.5
            )
            return .image(image)
        case .alignment:
            return .asset(.X32.Align.left)
        }
    }

    var displayData: SlashMenuItemDisplayData {
        SlashMenuItemDisplayData(iconData: iconName, title: self.title)
    }
}
