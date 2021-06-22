
enum BlockActionType {
    case style(BlockStyleAction)
    case media(BlockMediaAction)
    case objects
    case relations
    case other(BlockOtherAction)
    case actions(BlockAction)
    case color(BlockColor)
    case background(BlockBackgroundColor)
    case alignment(BlockAlignmentAction)
    
    var displayData: SlashMenuItemDisplayData {
        switch self {
        case let .actions(action):
            return SlashMenuItemDisplayData(imageName: action.iconName, title: action.title)
        case let .alignment(alignment):
            return SlashMenuItemDisplayData(imageName: alignment.iconName, title: alignment.title)
        case let .background(color):
            return SlashMenuItemDisplayData(imageName: color.iconName, title: color.title)
        case let .color(color):
            return SlashMenuItemDisplayData(imageName: color.iconName, title: color.title)
        case let .media(media):
            return SlashMenuItemDisplayData(imageName: media.iconName, title: media.title, subtitle: media.subtitle)
        case let .style(style):
            return SlashMenuItemDisplayData(imageName: style.iconName, title: style.title, subtitle: style.subtitle)
        case let .other(other):
            return SlashMenuItemDisplayData(imageName: other.iconName, title: other.title)
        case .objects, .relations:
            return SlashMenuItemDisplayData(imageName: "", title: "")
        }
    }
}
