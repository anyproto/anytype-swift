import Foundation
import BlocksModels

protocol EditorPageViewModelProtocol {
    var document: BaseDocumentProtocol { get }
    var wholeBlockMarkupViewModel: MarkupViewModel { get }
    var objectSettingsViewModel: ObjectSettingsViewModel { get }
    
    var modelsHolder: ObjectContentViewModelsSharedHolder { get }
    
    var blockActionHandler: EditorActionHandlerProtocol { get }
    
    func viewLoaded()
    func viewAppeared()
    func viewWillDismiss()

    func didSelectBlock(at index: IndexPath)
    
    func showSettings()
    
    func showIconPicker()
    func showCoverPicker()
    
    var router: EditorRouterProtocol { get }
}
