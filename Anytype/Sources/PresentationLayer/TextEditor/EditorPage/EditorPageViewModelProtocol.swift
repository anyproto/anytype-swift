import Foundation
import BlocksModels
import Combine

protocol EditorPageViewModelProtocol: AnyObject {
    var blocksStateManager: EditorPageBlocksStateManagerProtocol { get }

    var document: BaseDocumentProtocol { get }
    var wholeBlockMarkupViewModel: MarkupViewModel { get }
    
    var modelsHolder: EditorMainItemModelsHolder { get }
    var actionHandler: BlockActionHandlerProtocol { get }
    
    var router: EditorRouterProtocol { get }
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()

    func didSelectBlock(at indexPath: IndexPath)

    func showSettings()
    
    func showIconPicker()
    func showCoverPicker()
    
    func setupSubscriptions()
}
