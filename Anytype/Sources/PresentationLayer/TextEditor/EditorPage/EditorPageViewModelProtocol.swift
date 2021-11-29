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
    
    func viewLoaded()
    func viewAppeared()

    func didSelectBlock(at indexPath: IndexPath)

    func showSettings()
    
    func showIconPicker()
    func showCoverPicker()
    
    var router: EditorRouterProtocol { get }
}
