import UIKit

enum SlashAction {
    case style(SlashActionStyle)
    case media(SlashActionMedia)
    case objects(SlashActionObject)
    case relations(SlashActionProperties)
    case other(SlashActionOther)
    case actions(BlockAction)
    case color(BlockColor)
    case background(BlockBackgroundColor)
    case alignment(SlashActionAlignment)

    @MainActor
    var displayData: NewSlashMenuItemDisplayData {
        switch self {
        case let .actions(action):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(action.iconAsset), title: action.title)
            )
        case let .alignment(alignment):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(alignment.iconAsset), title: alignment.title)
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
                SlashMenuItemDisplayData(iconData: .asset(media.iconAsset), title: media.title, titleSynonyms: media.titleSynonyms, subtitle: media.subtitle)
            )
        case let .style(style):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(style.imageAsset), title: style.title, subtitle: style.subtitle, expandedIcon: true)
            )
        case let .other(other):
            return .titleSubtitleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(other.iconAsset), title: other.title, searchAliases: other.searchAliases)
            )
        case let .objects(object):
            switch object {
            case .linkTo:
                return .titleSubtitleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: .asset(.X40.linkToExistingObject),
                        title: Loc.addLink,
                        subtitle: Loc.SlashMenu.LinkTo.description
                    )
                )
            case .date:
                return .titleSubtitleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: .object(.emptyDateIcon),
                        title: Loc.selectDate
                    )
                )
            case .objectType(let objectType):
                return .titleSubtitleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: objectType.objectIconImage,
                        title: objectType.objectName.isEmpty ? Loc.untitled : objectType.objectName,
                        subtitle: objectType.description
                    )
                )
            }
        case let .relations(relationAction):
            switch relationAction {
            case .newRealtion:
                return .titleSubtitleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: .asset(.X24.plus),
                        title: Loc.newField
                    )
                )
            case .relation(let relation):
                return  .relationDisplayData(relation)
            }
        }
    }
}
