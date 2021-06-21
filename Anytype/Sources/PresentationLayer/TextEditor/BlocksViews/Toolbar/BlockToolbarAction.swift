import Foundation
import UIKit

enum BlockToolbarAction {
    enum EditAction {
        case delete, duplicate
    }
    
    enum BookmarkAction {
        case fetch(URL)
    }
    
    case addBlock(BlockToolbarBlocksTypes)
    case turnIntoBlock(BlockToolbarBlocksTypes)
    
    case editBlock(EditAction)
    case bookmark(BookmarkAction)
}
