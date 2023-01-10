import Foundation
import SwiftUI

@MainActor
protocol HomeWidgetsCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class HomeWidgetsCoordinator: HomeWidgetsCoordinatorProtocol, HomeWidgetsModuleOutput {
    
    private let homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol
    private let accountManager: AccountManager
    private let navigationContext: NavigationContextProtocol
    private let windowManager: WindowManager
    private let createWidgetCoordinator: CreateWidgetCoordinatorProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    
    init(
        homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol,
        accountManager: AccountManager,
        navigationContext: NavigationContextProtocol,
        windowManager: WindowManager,
        createWidgetCoordinator: CreateWidgetCoordinatorProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    ) {
        self.homeWidgetsModuleAssembly = homeWidgetsModuleAssembly
        self.accountManager = accountManager
        self.navigationContext = navigationContext
        self.windowManager = windowManager
        self.createWidgetCoordinator = createWidgetCoordinator
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
    }
    
    func startFlow() -> AnyView {
        return homeWidgetsModuleAssembly.make(widgetObjectId: accountManager.account.info.widgetsId, output: self)
    }
    
    // MARK: - HomeWidgetsModuleOutput
    
    func onOldHomeSelected() {
        windowManager.showHomeWindow()
    }
    
    func onCreateWidgetSelected() {
        createWidgetCoordinator.startFlow(widgetObjectId: accountManager.account.info.widgetsId)
    }
    
    func onSpaceIconChangeSelected(objectId: String) {
        Task { @MainActor in
            let document = BaseDocument(objectId: objectId)
            try? await document.open()
            let module = objectIconPickerModuleAssembly.make(document: document)
            navigationContext.present(module)
        }
    }
}
