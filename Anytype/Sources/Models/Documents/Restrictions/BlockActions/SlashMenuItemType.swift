
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
            return "TextEditor/Toolbar/Blocks/Style"
        case .media:
            return "TextEditor/Toolbar/Blocks/Media"
        case .objects:
            return "TextEditor/Toolbar/Blocks/Objects"
        case .relations:
            return "TextEditor/Toolbar/Blocks/Relation"
        case .other:
            return "TextEditor/Toolbar/Blocks/Other"
        case .actions:
            return "TextEditor/Toolbar/Blocks/Actions"
        case .color:
            return "TextEditor/Toolbar/Blocks/ColorBlack"
        case .background:
            return "TextEditor/Toolbar/Blocks/BackgroundColorClear"
        case .alignment:
            return "TextEditor/Toolbar/Blocks/AlignmentLeft"
        }
    }

    var displayData: SlashMenuItemDisplayData {
        SlashMenuItemDisplayData(iconData: .imageNamed(iconName), title: self.title)
    }
}
