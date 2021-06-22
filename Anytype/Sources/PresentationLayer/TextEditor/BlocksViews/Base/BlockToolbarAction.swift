import Foundation
import UIKit

enum BlockToolbarAction {
    enum EditAction {
        case delete, duplicate
    }
    
    case addBlock(BlockToolbarBlocksTypes)
    case turnIntoBlock(BlockToolbarBlocksTypes)
    
    case editBlock(EditAction)
    case fetch(url: URL)
}
