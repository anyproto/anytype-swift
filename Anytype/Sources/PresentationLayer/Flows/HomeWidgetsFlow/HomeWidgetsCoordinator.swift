import Foundation
import SwiftUI

@MainActor
protocol HomeWidgetsCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class HomeWidgetsCoordinator: HomeWidgetsCoordinatorProtocol, HomeWidgetsModuleOutput,
                                    CommonWidgetModuleOutput, HomeBottomPanelModuleOutput {
    
    // MARK: - DI
    
    private let homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol
    private let accountManager: AccountManagerProtocol
    private let navigationContext: NavigationContextProtocol
    private let windowManager: WindowManager
    private let createWidgetCoordinator: CreateWidgetCoordinatorProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol
    private let editorBrowserCoordinator: EditorBrowserCoordinatorProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    
    init(
        homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol,
        accountManager: AccountManagerProtocol,
        navigationContext: NavigationContextProtocol,
        windowManager: WindowManager,
        createWidgetCoordinator: CreateWidgetCoordinatorProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol,
        editorBrowserCoordinator: EditorBrowserCoordinatorProtocol,
        searchModuleAssembly: SearchModuleAssemblyProtocol
    ) {
        self.homeWidgetsModuleAssembly = homeWidgetsModuleAssembly
        self.accountManager = accountManager
        self.navigationContext = navigationContext
        self.windowManager = windowManager
        self.createWidgetCoordinator = createWidgetCoordinator
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.widgetObjectListModuleAssembly = widgetObjectListModuleAssembly
        self.editorBrowserCoordinator = editorBrowserCoordinator
        self.searchModuleAssembly = searchModuleAssembly
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
        openObject(screenData: screenData)
    }
    
    // MARK: - HomeBottomPanelModuleOutput
    
    func onCreateWidgetSelected() {
        createWidgetCoordinator.startFlow(widgetObjectId: accountManager.account.info.widgetsId)
    }
    
    func onSearchSelected() {
        let module = searchModuleAssembly.makeObjectSearch(title: nil, context: .general, onSelect: { [weak self] data in
            let screenData = EditorScreenData(pageId: data.blockId, type: data.viewType)
            self?.navigationContext.dismissAllPresented()
            self?.openObject(screenData: screenData)
        })
        navigationContext.present(module)
    }
    
    // MARK: - Private
    
    private func openObject(screenData: EditorScreenData) {
        editorBrowserCoordinator.startFlow(data: screenData)
    }
}
