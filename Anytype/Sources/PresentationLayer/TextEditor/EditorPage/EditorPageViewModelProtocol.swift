import Foundation
import BlocksModels

protocol EditorPageViewModelProtocol {
    var documentId: BlockId { get }
    var document: BaseDocumentProtocol { get }
    var wholeBlockMarkupViewModel: MarkupViewModel { get }
    var objectSettingsViewModel: ObjectSettingsViewModel { get }
    
    var modelsHolder: ObjectContentViewModelsSharedHolder { get }
    
    var blockActionHandler: EditorActionHandlerProtocol { get }
    
    func viewLoaded()
    func didSelectBlock(at index: IndexPath)
    
    func showSettings()
    
    func showIconPicker()
    func showCoverPicker()
    
    var router: EditorRouterProtocol { get }
}
