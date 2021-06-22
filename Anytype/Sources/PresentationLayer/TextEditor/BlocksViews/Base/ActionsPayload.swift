import BlocksModels
import UIKit

enum ActionPayload {
    case toolbar(model: BlockActiveRecordModelProtocol, action: BlockToolbarAction)
    
    case textView(model: BlockActiveRecordModelProtocol, action: TextBlockUserInteraction)
    case uploadFile(model: BlockActiveRecordModelProtocol, filePath: String)
    case showStyleMenu(model: BlockModelProtocol, viewModel: BaseBlockViewModel)
    
    case showCodeLanguageView(languages: [String], completion: (String) -> Void)
}
