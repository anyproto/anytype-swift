import UIKit
import BlocksModels

enum BlockHandlerActionType {
    enum TextAttributesType: CaseIterable {
        case bold
        case italic
        case strikethrough
        case keyboard
    }

    case toggleWholeBlockMarkup(TextAttributesType)
    case toggleFontStyle(TextAttributesType, NSRange)
    case setLink(URL?, NSRange)
    case setLinkToObject(linkBlockId: BlockId, NSRange)
    
    case addLink(BlockId)
    case addBlock(BlockContentType)
}
