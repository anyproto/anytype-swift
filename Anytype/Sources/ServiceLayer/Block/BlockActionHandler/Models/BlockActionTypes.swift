import UIKit
import BlocksModels



enum BlockHandlerActionType {
    case toggleFontStyle(TextAttributesType, NSRange)
    case setLink(URL?, NSRange)
    case setLinkToObject(linkBlockId: BlockId, NSRange)
    
    case addLink(BlockId)
    case addBlock(BlockContentType)
}
