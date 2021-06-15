import Foundation
import UIKit

extension BlockToolbar {
    typealias BlockType = BlockToolbar.AddBlock.BlocksTypes
    
    enum UnderlyingAction {
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
        
        case addBlock(BlockType)
        case turnIntoBlock(BlockType)
        case changeColor(ChangeColor)
        case editBlock(EditAction)
        case bookmark(BookmarkAction)
    }
}
