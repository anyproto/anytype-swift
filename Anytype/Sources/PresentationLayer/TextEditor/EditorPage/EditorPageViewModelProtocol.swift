import Foundation
import BlocksModels
import Combine

protocol EditorPageViewModelProtocol {
    var document: BaseDocumentProtocol { get }
    var wholeBlockMarkupViewModel: MarkupViewModel { get }
    var objectSettingsViewModel: ObjectSettingsViewModel { get }
    
    var modelsHolder: ObjectContentViewModelsSharedHolder { get }
    
    var blockActionHandler: EditorActionHandlerProtocol { get }

    var editorEditingState: AnyPublisher<EditorEditingState, Never> { get }
    
    func viewLoaded()
    func viewAppeared()

    func didSelectBlock(at index: IndexPath)
    
    func showSettings()
    
    func showIconPicker()
    func showCoverPicker()
    
    var router: EditorRouterProtocol { get }
}
