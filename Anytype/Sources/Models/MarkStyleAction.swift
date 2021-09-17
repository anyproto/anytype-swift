import UIKit
import BlocksModels

enum MarkStyleAction: Equatable {
    
    case bold(Bool)
    case italic(Bool)
    case keyboard(Bool)
    case strikethrough(Bool)
    case underscored(Bool)
    case textColor(UIColor)
    case backgroundColor(UIColor)
    case link(URL?)
    case mention(image: ObjectIconImage?, blockId: BlockId)
    
}
