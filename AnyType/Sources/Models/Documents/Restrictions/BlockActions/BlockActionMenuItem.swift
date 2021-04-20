
import Foundation

enum BlockActionMenuItem {
    case menu(BlockMenuItemType, [BlockActionMenuItem])
    case action(BlockActionType)
    case sectionDivider(String)
}
