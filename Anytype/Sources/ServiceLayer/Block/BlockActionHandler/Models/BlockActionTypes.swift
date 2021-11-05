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
    case toggleFontStyle(NSAttributedString, TextAttributesType, NSRange)
    case setLink(NSAttributedString, URL?, NSRange)
    case setLinkToObject(linkBlockId: BlockId, NSAttributedString, NSRange)
    
    case addLink(BlockId)
    case addBlock(BlockContentType)
    case createEmptyBlock(parentId: BlockId)
}
