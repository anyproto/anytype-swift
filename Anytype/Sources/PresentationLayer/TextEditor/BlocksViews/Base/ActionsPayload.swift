import BlocksModels
import UIKit

typealias TextViewAction = CustomTextView.UserAction
enum ActionPayload {
    case textView(block: BlockActiveRecordModelProtocol, action: TextViewAction)
    
    case uploadFile(block: BlockActiveRecordModelProtocol, filePath: String)
    case showStyleMenu(block: BlockModelProtocol, viewModel: BaseBlockViewModel)
    
    case showCodeLanguageView(languages: [String], completion: (String) -> Void)
}
