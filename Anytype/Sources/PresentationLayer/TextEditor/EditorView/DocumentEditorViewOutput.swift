import Foundation

protocol DocumentEditorViewOutput {
    var document: BaseDocumentProtocol { get }
    var wholeBlockMarkupViewModel: MarkupViewModel { get }
    var objectSettingsViewModel: ObjectSettingsViewModel { get }
    
    var modelsHolder: ObjectContentViewModelsSharedHolder { get }
    
    var selectionHandler: EditorModuleSelectionHandlerProtocol { get }
    var blockActionHandler: EditorActionHandlerProtocol { get }
    
    func viewLoaded()
    func didSelectBlock(at index: IndexPath)
    
    func showSettings()
}
