import Foundation

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
    
    var iconName: String {
        switch self {
        case .style:
            return ImageName.slashMenu.groups.style
        case .media:
            return ImageName.slashMenu.groups.media
        case .objects:
            return ImageName.slashMenu.groups.objects
        case .relations:
            return ImageName.slashMenu.groups.relation
        case .other:
            return ImageName.slashMenu.groups.other
        case .actions:
            return ImageName.slashMenu.groups.actions
        case .color:
            return ImageName.slashMenu.groups.color
        case .background:
            return ImageName.slashMenu.groups.background_color
        case .alignment:
            return ImageName.slashMenu.groups.alignment
        }
    }

    var displayData: SlashMenuItemDisplayData {
        SlashMenuItemDisplayData(iconData: .staticImage(iconName), title: self.title)
    }
}
