import BlocksModels
import UIKit

typealias TextViewAction = CustomTextView.UserAction

enum ActionPayload {
    case toolbar(model: BlockActiveRecordModelProtocol, action: BlockToolbarAction)
    
    case buttonView(model: BlockActiveRecordModelProtocol, action: ButtonAction)
    case textView(model: BlockActiveRecordModelProtocol, action: TextViewAction)
    
    case uploadFile(model: BlockActiveRecordModelProtocol, filePath: String)
    case showStyleMenu(model: BlockModelProtocol, viewModel: BaseBlockViewModel)
    
    case showCodeLanguageView(languages: [String], completion: (String) -> Void)
}


extension ActionPayload {
    enum ButtonAction {
        enum Toggle {
            case toggled(Bool)
            case insertFirst(Bool)
        }
        case toggle(Toggle)
        case checkbox(Bool)
    }
}

