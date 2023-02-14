import Foundation

protocol EditorBrowserCoordinatorProtocol: AnyObject {
    func startFlow(data: EditorScreenData)
}

final class EditorBrowserCoordinator: EditorBrowserCoordinatorProtocol, EditorPageOpenRouterProtocol {
    
    // MARK: - DI
    
    private let navigationContext: NavigationContextProtocol
    private let editorBrowserAssembly: EditorBrowserAssembly
    private let editorPageCoordinatorAssembly: EditorPageCoordinatorAssemblyProtocol
    
    // MARK: - State
    
    private var editorPageCoordinator: EditorPageCoordinatorProtocol?
    private weak var browserController: EditorBrowserController?
    
    init(
        navigationContext: NavigationContextProtocol,
        editorBrowserAssembly: EditorBrowserAssembly,
        editorPageCoordinatorAssembly: EditorPageCoordinatorAssemblyProtocol
    ) {
        self.navigationContext = navigationContext
        self.editorBrowserAssembly = editorBrowserAssembly
        self.editorPageCoordinatorAssembly = editorPageCoordinatorAssembly
    }
    
    func startFlow(data: EditorScreenData) {
        showPage(data: data)
    }
    
    // MARK: - EditorPageOpenRouterProtocol
    
    func showPage(data: EditorScreenData) {
        if browserController != nil {
            editorPageCoordinator?.startFlow(data: data, replaceCurrentPage: false)
        } else {
            let controller = editorBrowserAssembly.buildEditorBrowser(data: data, router: self, addRoot: false)
            navigationContext.push(controller)
            browserController = controller
            editorPageCoordinator = editorPageCoordinatorAssembly.make(browserController: browserController)
            editorPageCoordinator?.startFlow(data: data, replaceCurrentPage: true)
        }
    }
}
