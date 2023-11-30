import Foundation
import Services
import Combine

@MainActor
protocol EditorPageViewModelProtocol: AnyObject {
    var blocksStateManager: EditorPageBlocksStateManagerProtocol { get }

    var document: BaseDocumentProtocol { get }
    
    var modelsHolder: EditorMainItemModelsHolder { get }
    var actionHandler: BlockActionHandlerProtocol { get }
    
    var router: EditorRouterProtocol { get }
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()
    func viewDidDissapear()

    func shakeMotionDidAppear()

    func didSelectBlock(at indexPath: IndexPath)
    func didFinishEditing(blockId: BlockId)
    
    func showSettings()
    func setupSubscriptions()
    
    func showTemplates()
    
    func cursorFocus(blockId: BlockId)
    
    func handleSettingsAction(action: ObjectSettingsAction)
}
