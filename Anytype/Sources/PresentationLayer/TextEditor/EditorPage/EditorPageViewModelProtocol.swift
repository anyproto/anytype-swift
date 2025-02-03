import Foundation
import Services
import Combine

@MainActor
protocol EditorPageViewModelProtocol: AnyObject {
    var blocksStateManager: any EditorPageBlocksStateManagerProtocol { get }

    var document: any BaseDocumentProtocol { get }
    
    var modelsHolder: EditorMainItemModelsHolder { get }
    var actionHandler: any BlockActionHandlerProtocol { get }
    
    var router: any EditorRouterProtocol { get }
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()
    func viewDidDissapear()

    func shakeMotionDidAppear()

    func didSelectBlock(at indexPath: IndexPath)
    func didFinishEditing(blockId: String)
    
    func showSettings()
    func setupSubscriptions()
    
    func showTemplates()
    
    func cursorFocus(blockId: String)
    
    func tapOnEmptyPlace()
    
    func showSyncStatusInfo()
}
