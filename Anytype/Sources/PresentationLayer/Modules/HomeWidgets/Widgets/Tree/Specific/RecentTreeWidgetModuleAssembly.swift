import Foundation
import SwiftUI

final class RecentTreeWidgetModuleAssembly: HomeWidgetCommonAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(serviceLocator: ServiceLocator, widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.serviceLocator = serviceLocator
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
    }
    
    // MARK: - HomeWidgetCommonAssemblyProtocol
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        
        let model = RecentWidgetInternalViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            recentSubscriptionService: serviceLocator.recentSubscriptionService()
        )
     
        return widgetsSubmoduleDI.treeWidgetModuleAssembly().make(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            stateManager: stateManager,
            internalModel: model,
            output: output
        )
    }
}
