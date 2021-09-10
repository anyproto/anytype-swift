
enum BlockActionType {
    case style(BlockStyleAction)
    case media(BlockMediaAction)
    case objects(ObjectType)
    case relations
    case other(BlockOtherAction)
    case actions(BlockAction)
    case color(BlockColor)
    case background(BlockBackgroundColor)
    case alignment(BlockAlignmentAction)
    
    var displayData: SlashMenuItemDisplayData {
        switch self {
        case let .actions(action):
            return SlashMenuItemDisplayData(iconData: .staticImage(action.iconName), title: action.title)
        case let .alignment(alignment):
            return SlashMenuItemDisplayData(iconData: .staticImage(alignment.iconName), title: alignment.title)
        case let .background(color):
            return SlashMenuItemDisplayData(iconData: .staticImage(color.iconName), title: color.title)
        case let .color(color):
            return SlashMenuItemDisplayData(iconData: .staticImage(color.iconName), title: color.title)
        case let .media(media):
            return SlashMenuItemDisplayData(iconData: .staticImage(media.iconName), title: media.title, subtitle: media.subtitle)
        case let .style(style):
            return SlashMenuItemDisplayData(iconData: .staticImage(style.iconName), title: style.title, subtitle: style.subtitle)
        case let .other(other):
            return SlashMenuItemDisplayData(iconData: .staticImage(other.iconName), title: other.title)
        case let .objects(object):
            return SlashMenuItemDisplayData(
                iconData: .icon(.emoji(object.iconEmoji)),
                title: object.name,
                subtitle: object.description
            )
        case .relations:
            return SlashMenuItemDisplayData(iconData: .staticImage(""), title: "")
        }
    }
}
