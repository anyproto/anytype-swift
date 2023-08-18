import Foundation

protocol EditorBrowserModuleAssemblyProtocol: AnyObject {
    func make() -> EditorBrowserCoordinatorProtocol
}

final class EditorBrowserModuleAssembly: EditorBrowserModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    private let coordinatorsID: CoordinatorsDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol, coordinatorsID: CoordinatorsDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
        self.coordinatorsID = coordinatorsID
    }
    
    func make() -> EditorBrowserCoordinatorProtocol {
        return EditorBrowserCoordinator(
            navigationContext: uiHelpersDI.commonNavigationContext(),
            editorBrowserAssembly: coordinatorsID.browser(),
            editorPageCoordinatorAssembly: coordinatorsID.editorPage()
        )
    }
}
