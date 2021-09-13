import UIKit
import BlocksModels

enum BlockHandlerActionType {
    enum TextAttributesType: CaseIterable {
        case bold
        case italic
        case strikethrough
        case keyboard
    }

    case turnInto(BlockText.Style)
    case setTextColor(BlockColor)
    case setBackgroundColor(BlockBackgroundColor)
    case toggleWholeBlockMarkup(TextAttributesType)
    case toggleFontStyle(NSAttributedString, TextAttributesType, NSRange)
    case setAlignment(LayoutAlignment)
    case setLink(NSAttributedString, URL?, NSRange)
    case setFields(contextID: BlockId, fields: [BlockFields])
    
    case duplicate
    case delete
    case addBlock(BlockContentType)
    case turnIntoBlock(BlockContentType)
    case createEmptyBlock(parentId: BlockId)
    
    case fetch(url: URL)
    
    case toggle
    case checkbox(selected: Bool)
    
    typealias TextViewAction = CustomTextView.UserAction
    case textView(action: TextViewAction, block: BlockModelProtocol)
}
