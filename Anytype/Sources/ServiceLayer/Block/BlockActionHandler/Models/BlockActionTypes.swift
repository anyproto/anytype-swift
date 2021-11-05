import UIKit
import BlocksModels

enum BlockHandlerActionType {
    enum TextAttributesType: CaseIterable {
        case bold
        case italic
        case strikethrough
        case keyboard
    }

    case moveTo(targetId: BlockId)
    case toggleWholeBlockMarkup(TextAttributesType)
    case toggleFontStyle(NSAttributedString, TextAttributesType, NSRange)
    case setAlignment(LayoutAlignment)
    case setLink(NSAttributedString, URL?, NSRange)
    case setLinkToObject(linkBlockId: BlockId, NSAttributedString, NSRange)
    
    case delete
    case addLink(BlockId)
    case addBlock(BlockContentType)
    case createEmptyBlock(parentId: BlockId)
    
    case fetch(url: URL)
    
    case toggle
    case checkbox(selected: Bool)
}
