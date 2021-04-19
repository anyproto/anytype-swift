
import Foundation

enum BlockActionMenuItem {
    case menuWithChildren(BlockMenuItemType, [BlockActionMenuItem])
    case action(BlockActionType)
    case sectionDivider(String)
}
