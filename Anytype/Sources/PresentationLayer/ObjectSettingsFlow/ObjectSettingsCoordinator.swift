import Foundation

protocol ObjectSettingsCoordinatorProtocol {
    func startFlow(document: BaseDocumentProtocol, router: EditorRouterProtocol)
}

final class ObjectSettingsCoordinator: ObjectSettingsCoordinatorProtocol, ObjectSettingswModelOutput {
    
    private let navigationContext: NavigationContextProtocol
    private let objectSettingsModuleAssembly: ObjectSettingModuleAssemblyProtocol
    private let undoRedoModuleAssembly: UndoRedoModuleAssemblyProtocol
    private let objectLayoutPickerModuleAssembly: ObjectLayoutPickerModuleAssemblyProtocol
    private let objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    
    private var document: BaseDocumentProtocol?
    
    init(
        navigationContext: NavigationContextProtocol,
        objectSettingsModuleAssembly: ObjectSettingModuleAssemblyProtocol,
        undoRedoModuleAssembly: UndoRedoModuleAssemblyProtocol,
        objectLayoutPickerModuleAssembly: ObjectLayoutPickerModuleAssemblyProtocol,
        objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    ) {
        self.navigationContext = navigationContext
        self.objectSettingsModuleAssembly = objectSettingsModuleAssembly
        self.undoRedoModuleAssembly = undoRedoModuleAssembly
        self.objectLayoutPickerModuleAssembly = objectLayoutPickerModuleAssembly
        self.objectCoverPickerModuleAssembly = objectCoverPickerModuleAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
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
    
    func layoutPickerAction() {
        guard let document = document else { return }
        let moduleViewController = objectLayoutPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }
    
    func coverPickerAction() {
        guard let document = document else { return }
        let moduleViewController = objectCoverPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }
    
    func iconPickerAction() {
        guard let document = document else { return }
        let moduleViewController = objectIconPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }
}
