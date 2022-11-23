import Foundation

protocol ObjectSettingsCoordinatorProtocol {
    func startFlow(document: BaseDocumentProtocol, router: EditorRouterProtocol)
}

final class ObjectSettingsCoordinator: ObjectSettingsCoordinatorProtocol, ObjectSettingswModelOutput {
    
    private let navigationContext: NavigationContextProtocol
    private let objectSettingsModuleAssembly: ObjectSettingModuleAssemblyProtocol
    private let undoRedoModuleAssembly: UndoRedoModuleAssemblyProtocol
    
    private var document: BaseDocumentProtocol?
    
    init(
        navigationContext: NavigationContextProtocol,
        objectSettingsModuleAssembly: ObjectSettingModuleAssemblyProtocol,
        undoRedoModuleAssembly: UndoRedoModuleAssemblyProtocol
    ) {
        self.navigationContext = navigationContext
        self.objectSettingsModuleAssembly = objectSettingsModuleAssembly
        self.undoRedoModuleAssembly = undoRedoModuleAssembly
    }
    
    func startFlow(document: BaseDocumentProtocol, router: EditorRouterProtocol) {
        self.document = document
        let moduleViewController = objectSettingsModuleAssembly.make(document: document, router: router, output: self)
        navigationContext.present(moduleViewController)
    }
    
    // MARK: - ObjectSettingswModelOutput
    
    func undoRedoAction() {
        guard let document = document else { return }
        let moduleViewController = undoRedoModuleAssembly.make(document: document)
        navigationContext.dismissTopPresented(animated: false)
        navigationContext.present(moduleViewController)
    }
    
}
