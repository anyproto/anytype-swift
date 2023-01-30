import Foundation
import SwiftUI

@MainActor
protocol HomeWidgetsCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class HomeWidgetsCoordinator: HomeWidgetsCoordinatorProtocol, HomeWidgetsModuleOutput,
                                    CommonWidgetModuleOutput, HomeBottomPanelModuleOutput, FavoritesWidgetModuleOutput {
    
    private let homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol
    private let accountManager: AccountManager
    private let navigationContext: NavigationContextProtocol
    private let windowManager: WindowManager
    private let createWidgetCoordinator: CreateWidgetCoordinatorProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let editorBrowserAssembly: EditorBrowserAssembly
    private let widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol
    
    private weak var browserController: EditorBrowserController?
    
    init(
        homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol,
        accountManager: AccountManager,
        navigationContext: NavigationContextProtocol,
        windowManager: WindowManager,
        createWidgetCoordinator: CreateWidgetCoordinatorProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        editorBrowserAssembly: EditorBrowserAssembly,
        widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol
    ) {
        self.homeWidgetsModuleAssembly = homeWidgetsModuleAssembly
        self.accountManager = accountManager
        self.navigationContext = navigationContext
        self.windowManager = windowManager
        self.createWidgetCoordinator = createWidgetCoordinator
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.editorBrowserAssembly = editorBrowserAssembly
        self.widgetObjectListModuleAssembly = widgetObjectListModuleAssembly
    }
    
    func startFlow() -> AnyView {
        return homeWidgetsModuleAssembly.make(
            widgetObjectId: accountManager.account.info.widgetsId,
            output: self,
            widgetOutput: self,
            bottomPanelOutput: self
        )
    }
    
    // MARK: - HomeWidgetsModuleOutput
    
    func onOldHomeSelected() {
        windowManager.showHomeWindow()
    }
    
    // TODO: Delete it. Temporary.
    func onSpaceIconChangeSelected(objectId: String) {
        Task { @MainActor in
            let document = BaseDocument(objectId: objectId)
            try? await document.open()
            let module = objectIconPickerModuleAssembly.make(document: document, objectId: document.objectId)
            navigationContext.present(module)
        }
    }
    
    // MARK: - CommonWidgetModuleOutput
        
    func onObjectSelected(screenData: EditorScreenData) {
        showPage(screenData: screenData)
    }
    
    // MARK: - FavoritesWidgetModuleOutput
    
    func onFavoritesSelected() {
        let module = widgetObjectListModuleAssembly.makeFavorites()
        navigationContext.push(module)
    }
    
    // MARK: - HomeBottomPanelModuleOutput
    
    func onCreateWidgetSelected() {
        createWidgetCoordinator.startFlow(widgetObjectId: accountManager.account.info.widgetsId)
    }
    
    // MARK: - Private
    
    private func showPage(screenData: EditorScreenData) {
        if let browserController {
            browserController.showPage(data: screenData)
        } else {
            let controller = editorBrowserAssembly.buildEditorBrowser(data: screenData)
            navigationContext.push(controller)
            browserController = controller
        }
    }
    
}
