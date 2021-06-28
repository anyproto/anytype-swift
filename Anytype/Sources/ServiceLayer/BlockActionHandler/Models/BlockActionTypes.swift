import UIKit
import BlocksModels

extension BlockActionHandler {
    /// Action on style view
    enum ActionType {
        enum TextAttributesType {
            case bold
            case italic
            case strikethrough
            case keyboard
        }

        case turnInto(BlockText.ContentType)
        case setTextColor(BlockColor)
        case setBackgroundColor(BlockBackgroundColor)
        case toggleFontStyle(TextAttributesType, NSRange = NSRange(location: 0, length: 0))
        case setAlignment(BlockInformationAlignment)
        case setLink(String)
        
        case duplicate
        case delete
        case addBlock(BlockViewType)
        case turnIntoBlock(BlockViewType)
        case createEmptyBlock(parentId: BlockId)
        
        case fetch(url: URL)
        case upload(filePath: String)
        
        case toggle
        case checkbox(selected: Bool)
        
        typealias TextViewAction = CustomTextView.UserAction
        case textView(action: TextViewAction, activeRecord: BlockActiveRecordProtocol)
    }
}
