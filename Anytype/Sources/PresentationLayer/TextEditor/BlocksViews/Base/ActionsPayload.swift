import BlocksModels
import UIKit

typealias TextViewAction = CustomTextView.UserAction
enum ActionPayload {
    case toolbar(block: BlockActiveRecordModelProtocol, action: BlockToolbarAction)
    case fetch(block: BlockActiveRecordModelProtocol, url: URL)
    
    case textView(block: BlockActiveRecordModelProtocol, action: TextViewAction)
    
    case uploadFile(block: BlockActiveRecordModelProtocol, filePath: String)
    case showStyleMenu(block: BlockModelProtocol, viewModel: BaseBlockViewModel)
    
    case showCodeLanguageView(languages: [String], completion: (String) -> Void)
    
    case checkboxTap(block: BlockActiveRecordModelProtocol, selected: Bool)
    case toggle(block: BlockActiveRecordModelProtocol, toggled: Bool)
}
