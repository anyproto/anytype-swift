
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
            return SlashMenuItemDisplayData(iconData: .imageNamed(action.iconName), title: action.title)
        case let .alignment(alignment):
            return SlashMenuItemDisplayData(iconData: .imageNamed(alignment.iconName), title: alignment.title)
        case let .background(color):
            return SlashMenuItemDisplayData(iconData: .imageNamed(color.iconName), title: color.title)
        case let .color(color):
            return SlashMenuItemDisplayData(iconData: .imageNamed(color.iconName), title: color.title)
        case let .media(media):
            return SlashMenuItemDisplayData(iconData: .imageNamed(media.iconName), title: media.title, subtitle: media.subtitle)
        case let .style(style):
            return SlashMenuItemDisplayData(iconData: .imageNamed(style.iconName), title: style.title, subtitle: style.subtitle)
        case let .other(other):
            return SlashMenuItemDisplayData(iconData: .imageNamed(other.iconName), title: other.title)
        case let .objects(object):
            return SlashMenuItemDisplayData(iconData: .emoji(object.emoji),
                                            title: object.name,
                                            subtitle: object.description)
        case .relations:
            return SlashMenuItemDisplayData(iconData: .imageNamed(""), title: "")
        }
    }
}
