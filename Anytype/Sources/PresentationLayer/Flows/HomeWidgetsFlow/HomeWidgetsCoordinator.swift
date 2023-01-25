import Foundation
import SwiftUI

@MainActor
protocol HomeWidgetsCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class HomeWidgetsCoordinator: HomeWidgetsCoordinatorProtocol, HomeWidgetsModuleOutput,
                                    CommonWidgetModuleOutput, HomeBottomPanelModuleOutput {
    
    private let homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol
    private let accountManager: AccountManager
    private let navigationContext: NavigationContextProtocol
    private let windowManager: WindowManager
    private let createWidgetCoordinator: CreateWidgetCoordinatorProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let editorBrowserAssembly: EditorBrowserAssembly
    
    private weak var browserController: EditorBrowserController?
    
    init(
        homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol,
        accountManager: AccountManager,
        navigationContext: NavigationContextProtocol,
        windowManager: WindowManager,
        createWidgetCoordinator: CreateWidgetCoordinatorProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        editorBrowserAssembly: EditorBrowserAssembly
    ) {
        self.homeWidgetsModuleAssembly = homeWidgetsModuleAssembly
        self.accountManager = accountManager
        self.navigationContext = navigationContext
        self.windowManager = windowManager
        self.createWidgetCoordinator = createWidgetCoordinator
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.editorBrowserAssembly = editorBrowserAssembly
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
            let module = objectIconPickerModuleAssembly.make(document: document)
            navigationContext.present(module)
        }
    }
    
    // MARK: - CommonWidgetModuleOutput
        
    func onObjectSelected(screenData: EditorScreenData) {
        showPage(screenData: screenData)
    }
    
    // MARK: - HomeBottomPanelModuleOutput
    
    func onCreateWidgetSelected() {
        createWidgetCoordinator.startFlow(widgetObjectId: accountManager.account.info.widgetsId)
    }
    
    // MARK: - Private
    
    func showPage(screenData: EditorScreenData) {
        if let browserController {
            browserController.showPage(data: screenData)
        } else {
            let controller = editorBrowserAssembly.buildEditorBrowser(data: screenData)
            navigationContext.push(controller)
            browserController = controller
        }
    }
}
