import Foundation
import SwiftUI

protocol HomeWidgetsModuleAssemblyProtocol {
    @MainActor
    func make(
        widgetObjectId: String,
        output: HomeWidgetsModuleOutput,
        treeWidgetOutput: ObjectTreeWidgetModuleOutput?,
        setWidgetOutput: SetWidgetModuleOutput?
    ) -> AnyView
}

final class HomeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    private let widgetsDI: WidgetsDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol, widgetsDI: WidgetsDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
        self.widgetsDI = widgetsDI
    }
    
    // MARK: - HomeWidgetsModuleAssemblyProtocol
    @MainActor
    func make(
        widgetObjectId: String,
        output: HomeWidgetsModuleOutput,
        treeWidgetOutput: ObjectTreeWidgetModuleOutput?,
        setWidgetOutput: SetWidgetModuleOutput?
    ) -> AnyView {
        let model = HomeWidgetsViewModel(
            widgetObject: HomeWidgetsObject(
                objectId: widgetObjectId,
                objectDetailsStorage: serviceLocator.objectDetailsStorage()
            ),
            registry: widgetsDI.homeWidgetsRegistry(treeWidgetOutput: treeWidgetOutput, setWidgetOutput: setWidgetOutput),
            blockWidgetService: serviceLocator.blockWidgetService(),
            accountManager: serviceLocator.accountManager(),
            bottomPanelProviderAssembly: widgetsDI.bottomPanelProviderAssembly(),
            toastPresenter: uiHelpersDI.toastPresenter,
            output: output
        )
        let view = HomeWidgetsView(model: model)
        return view.eraseToAnyView()
    }
}
