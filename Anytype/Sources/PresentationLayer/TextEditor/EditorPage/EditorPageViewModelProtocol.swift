import Foundation
import BlocksModels
import Combine

protocol EditorPageViewModelProtocol: BlocksSelectionDelegate {
    var document: BaseDocumentProtocol { get }
    var wholeBlockMarkupViewModel: MarkupViewModel { get }
    var objectSettingsViewModel: ObjectSettingsViewModel { get }
    
    var modelsHolder: BlockViewModelsHolder { get }
    var actionHandler: BlockActionHandlerProtocol { get }

    var editorEditingState: AnyPublisher<EditorEditingState, Never> { get }
    
    func viewLoaded()
    func viewAppeared()

    func didSelectBlock(at index: IndexPath)

    func didUpdateSelectedIndexPaths(_ indexPaths: [IndexPath])
    
    func showSettings()
    
    func showIconPicker()
    func showCoverPicker()
    
    var router: EditorRouterProtocol { get }
}
