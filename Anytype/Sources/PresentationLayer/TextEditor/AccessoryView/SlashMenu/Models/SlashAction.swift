import UIKit

enum SlashAction {
    case single(SlashActionSingle)
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
            return .titleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(action.iconAsset), title: action.title)
            )
        case let .alignment(alignment):
            return .titleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(alignment.iconAsset), title: alignment.title)
                )
        case let .background(color):
            return .titleDisplayData(
                SlashMenuItemDisplayData(iconData: .image(color.image), title: color.title)
            )
        case let .color(color):
            return .titleDisplayData(
                SlashMenuItemDisplayData(iconData: .image(color.image), title: color.title)
            )
        case let .media(media):
            return .titleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(media.iconAsset), title: media.title, titleSynonyms: media.titleSynonyms)
            )
        case let .single(single):
            return .titleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(single.iconAsset), title: single.title, titleSynonyms: single.titleSynonyms)
            )
        case let .style(style):
            return .titleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(style.imageAsset), title: style.title, expandedIcon: true)
            )
        case let .other(other):
            return .titleDisplayData(
                SlashMenuItemDisplayData(iconData: .asset(other.iconAsset), title: other.title, searchAliases: other.searchAliases)
            )
        case let .objects(object):
            switch object {
            case .date:
                return .titleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: .object(.emptyDateIcon),
                        title: Loc.selectDate
                    )
                )
            case .objectType(let objectType):
                return .titleDisplayData(
                    SlashMenuItemDisplayData(
                        iconData: objectType.objectIconImage,
                        title: objectType.objectName.isEmpty ? Loc.untitled : objectType.objectName
                    )
                )
            }
        case let .relations(relationAction):
            switch relationAction {
            case .newRealtion:
                return .titleDisplayData(
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
