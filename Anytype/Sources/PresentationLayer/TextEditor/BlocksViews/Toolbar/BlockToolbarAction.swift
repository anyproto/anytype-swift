import Foundation
import UIKit

enum BlockToolbarAction {
    enum ChangeColor {
        case textColor(UIColor)
        case backgroundColor(UIColor)
    }
    
    enum EditAction {
        case delete, duplicate
    }
    
    enum BookmarkAction {
        case fetch(URL)
    }
    
    case addBlock(BlockToolbarBlocksTypes)
    case turnIntoBlock(BlockToolbarBlocksTypes)
    case changeColor(ChangeColor)
    case editBlock(EditAction)
    case bookmark(BookmarkAction)
}
