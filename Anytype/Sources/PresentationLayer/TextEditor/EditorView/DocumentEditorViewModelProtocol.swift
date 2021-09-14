import Foundation

protocol DocumentEditorViewModelProtocol {
    var document: BaseDocumentProtocol { get }
    var wholeBlockMarkupViewModel: MarkupViewModel { get }
    var objectSettingsViewModel: ObjectSettingsViewModel { get }
    
    var modelsHolder: ObjectContentViewModelsSharedHolder { get }
    
    var blockActionHandler: EditorActionHandlerProtocol { get }
    
    func viewLoaded()
    
    func showSettings()
}
