import Services
import UIKit

enum TextBlockUsecase {
    case editor
    case simpleTable
}

struct TextBlockDelegateData {
    let textView: UITextView
    
    let info: BlockInformation
    let text: UIKitAnytypeText
    let usecase: TextBlockUsecase
}
