enum SlashAction {
    case style(SlashActionStyle)
    case media(SlashActionMedia)
    case objects(SlashActionObject)
    case relations
    case other(SlashActionOther)
    case actions(BlockAction)
    case color(BlockColor)
    case background(BlockBackgroundColor)
    case alignment(SlashActionAlignment)
    
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
            return SlashMenuItemDisplayData(iconData: .staticImage(style.iconName), title: style.title, subtitle: style.subtitle, expandedIcon: true)
        case let .other(other):
            return SlashMenuItemDisplayData(iconData: .staticImage(other.iconName), title: other.title)
        case let .objects(object):
            switch object {
            case .linkTo:
                return SlashMenuItemDisplayData(
                    iconData: .staticImage(ImageName.slashMenu.link_to),
                    title: "Link to object".localized,
                    subtitle: "Link to existing object".localized
                )
            case .objectType(let objectType):
                return SlashMenuItemDisplayData(
                    iconData: objectType.icon.flatMap { .icon($0) } ?? .placeholder(objectType.name.first),
                    title: objectType.name,
                    subtitle: objectType.description
                )
            }
        case .relations:
            return SlashMenuItemDisplayData(iconData: .staticImage(""), title: "")
        }
    }
}
