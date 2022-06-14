enum SlashAction {
    case style(SlashActionStyle)
    case media(SlashActionMedia)
    case objects(SlashActionObject)
    case relations(SlashActionRelations)
    case other(SlashActionOther)
    case actions(BlockAction)
    case color(BlockColor)
    case background(BlockBackgroundColor)
    case alignment(SlashActionAlignment)

    var displayData: NewSlashMenuItemDisplayData {
        switch self {
        case let .actions(action):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .staticImage(action.iconName), title: action.title)
            )
        case let .alignment(alignment):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .staticImage(alignment.iconName), title: alignment.title)
                )
        case let .background(color):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .image(color.image), title: color.title)
            )
        case let .color(color):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .image(color.image), title: color.title)
            )
        case let .media(media):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .staticImage(media.iconName), title: media.title, subtitle: media.subtitle)
            )
        case let .style(style):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .staticImage(style.iconName), title: style.title, subtitle: style.subtitle, expandedIcon: true)
            )
        case let .other(other):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .staticImage(other.iconName), title: other.title, searchAliases: other.searchAliases)
            )
        case let .objects(object):
            switch object {
            case .linkTo:
                return .titleSubtitleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: .staticImage(ImageName.slashMenu.link_to),
                        title: "Link to object".localized,
                        subtitle: "Link to existing object".localized
                    )
                )
            case .objectType(let objectType):
                return .titleSubtitleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: objectType.icon.flatMap { .icon($0) } ?? .placeholder(objectType.name.first),
                        title: objectType.name,
                        subtitle: objectType.description
                    )
                )
            }
        case let .relations(relationAction):
            switch relationAction {
            case .newRealtion:
                return .titleSubtitleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: .staticImage(ImageName.slashMenu.relations.addRelation),
                        title: "New relation".localized
                    )
                )
            case .relation(let relation):
                return  .relationDisplayData(relation)
            }
        }
    }
}
