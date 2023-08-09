import Foundation
import SwiftUI

final class RecentListWidgetModuleAssembly: HomeWidgetCommonAssemblyProtocol {
    
    private let type: RecentWidgetType
    private let serviceLocator: ServiceLocator
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(type: RecentWidgetType, serviceLocator: ServiceLocator, widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.type = type
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
            type: type,
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            recentSubscriptionService: serviceLocator.recentSubscriptionService()
        )
     
        return widgetsSubmoduleDI.listWidgetModuleAssembly().make(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            style: .list,
            stateManager: stateManager,
            internalModel: model,
            output: output
        )
    }
}
