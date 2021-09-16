import UIKit
import BlocksModels

enum MarkStyleAction: Equatable {
    
    case bold(Bool = true)
    case italic(Bool = true)
    case keyboard(Bool = true)
    case strikethrough(Bool = true)
    case underscored(Bool = true)
    case textColor(UIColor?)
    case backgroundColor(UIColor?)
    case link(URL?)
    case mention(blockId: BlockId?)
    
}
