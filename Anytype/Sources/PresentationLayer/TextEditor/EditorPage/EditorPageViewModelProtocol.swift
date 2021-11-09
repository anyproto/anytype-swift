import Foundation
import BlocksModels
import Combine

protocol EditorPageViewModelProtocol {
    var document: BaseDocumentProtocol { get }
    var wholeBlockMarkupViewModel: MarkupViewModel { get }
    var objectSettingsViewModel: ObjectSettingsViewModel { get }
    
    var modelsHolder: BlockViewModelsHolder { get }
    
<<<<<<< HEAD
    var blockActionHandler: EditorActionHandlerProtocol { get }

    var editorEditingState: AnyPublisher<EditorEditingState, Never> { get }
=======
    var actionHandler: BlockActionHandlerProtocol { get }
>>>>>>> 5e17a9f33411c5509928c824f5e8611cbb7d7948
    
    func viewLoaded()
    func viewAppeared()

    func didSelectBlock(at index: IndexPath)
    
    func showSettings()
    
    func showIconPicker()
    func showCoverPicker()
    
    var router: EditorRouterProtocol { get }
}
