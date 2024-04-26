import Foundation
import SwiftUI

final class SpaceWidgetModuleAssembly: HomeWidgetCommonAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - HomeWidgetCommonAssemblyProtocol
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        return SpaceWidgetView(model: SpaceWidgetViewModel(
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            subscriptionService: serviceLocator.singleObjectSubscriptionService(),
            output: output
        )).eraseToAnyView()
    }
}
