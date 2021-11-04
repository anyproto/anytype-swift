import BlocksModels
import UIKit

struct TextBlockDelegateData {
    let textView: UITextView
    
    let block: BlockModelProtocol
    let text: UIKitAnytypeText
    
    var info: BlockInformation {
        block.information
    }
}
