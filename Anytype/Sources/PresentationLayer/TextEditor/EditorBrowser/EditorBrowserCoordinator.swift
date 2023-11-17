import Foundation

protocol EditorBrowserCoordinatorProtocol: AnyObject {
    @MainActor
    func startFlow(data: EditorScreenData, delegate: EditorBrowserDelegate?)
    @MainActor
    func dismissAllPages()
    @MainActor
    func isEmpty() -> Bool
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
    
    @MainActor
    func startFlow(data: EditorScreenData, delegate: EditorBrowserDelegate?) {
        showPage(data: data, delegate: delegate)
    }
    
    @MainActor
    func dismissAllPages() {
        navigationContext.pop(animated: true)
    }
    
    @MainActor
    func isEmpty() -> Bool {
        browserController.isNil
    }
    
    // MARK: - EditorPageOpenRouterProtocol
    
    @MainActor
    func showPage(data: EditorScreenData) {
        showPage(data: data, delegate: nil)
    }
    
    // MARK: - Private
    
    @MainActor
    private func showPage(data: EditorScreenData, delegate: EditorBrowserDelegate?) {
        if browserController != nil {
            editorPageCoordinator?.startFlow(data: data, replaceCurrentPage: false)
        } else {
            let controller = editorBrowserAssembly.buildEditorBrowser(data: data, router: self, addRoot: false)
            controller.delegate = delegate
            editorPageCoordinator = editorPageCoordinatorAssembly.make(browserController: controller)
            editorPageCoordinator?.startFlow(data: data, replaceCurrentPage: true)
            navigationContext.push(controller)
            browserController = controller
        }
    }
}
