
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
    
    var displayData: BlockMenuItemSimpleDisplayData {
        switch self {
        case let .actions(action):
            return BlockMenuItemSimpleDisplayData(imageName: action.iconName, title: action.title)
        case let .alignment(alignment):
            return BlockMenuItemSimpleDisplayData(imageName: alignment.iconName, title: alignment.title)
        case let .background(color):
            return BlockMenuItemSimpleDisplayData(imageName: color.iconName, title: color.title)
        case let .color(color):
            return BlockMenuItemSimpleDisplayData(imageName: color.iconName, title: color.title)
        case let .media(media):
            return BlockMenuItemSimpleDisplayData(imageName: media.iconName, title: media.title, subtitle: media.subtitle)
        case let .style(style):
            return BlockMenuItemSimpleDisplayData(imageName: style.iconName, title: style.title, subtitle: style.subtitle)
        case let .other(other):
            return BlockMenuItemSimpleDisplayData(imageName: other.iconName, title: other.title)
        case .objects, .relations:
            return BlockMenuItemSimpleDisplayData(imageName: "", title: "")
        }
    }
}
