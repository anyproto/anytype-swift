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
                SlashMenuItemDisplayData(iconData: .imageAsset(action.iconAsset), title: action.title)
            )
        case let .alignment(alignment):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .imageAsset(alignment.iconAsset), title: alignment.title)
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
                SlashMenuItemDisplayData(iconData: .imageAsset(media.iconAsset), title: media.title, subtitle: media.subtitle)
            )
        case let .style(style):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .imageAsset(style.iconAsset), title: style.title, subtitle: style.subtitle, expandedIcon: true)
            )
        case let .other(other):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .imageAsset(other.iconAsset), title: other.title, searchAliases: other.searchAliases)
            )
        case let .objects(object):
            switch object {
            case .linkTo:
                return .titleSubtitleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: .imageAsset(.slashMenuLinkTo),
                        title: Loc.linkToObject,
                        subtitle: Loc.linkToExistingObject
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
                        iconData: .imageAsset(.slashMenuAddRelation),
                        title: Loc.newRelation
                    )
                )
            case .relation(let relation):
                return  .relationDisplayData(relation)
            }
        }
    }
}
