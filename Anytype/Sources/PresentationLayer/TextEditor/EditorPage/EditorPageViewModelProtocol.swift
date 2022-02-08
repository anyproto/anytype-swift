import Foundation
import BlocksModels
import Combine

protocol EditorPageViewModelProtocol {
    var blocksStateManager: EditorPageBlocksStateManagerProtocol { get }

    var document: BaseDocumentProtocol { get }
    var wholeBlockMarkupViewModel: MarkupViewModel { get }
    var objectSettingsViewModel: ObjectSettingsViewModel { get }
    
    var modelsHolder: BlockViewModelsHolder { get }
    var actionHandler: BlockActionHandlerProtocol { get }
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()

    func didSelectBlock(at indexPath: IndexPath)

    func showSettings()
    
    func showIconPicker()
    func showCoverPicker()
    
    var router: EditorRouterProtocol { get }
}
