import Foundation
import SwiftUI

final class SetCompactListWidgetModuleAssembly: HomeWidgetCommonAssemblyProtocol {
    
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
        
        let model = SetObjectWidgetInternalViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            setSubscriptionDataBuilder: SetSubscriptionDataBuilder(
                activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage()
            ),
            output: output
        )
     
        return widgetsSubmoduleDI.listWidgetModuleAssembly().make(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            style: .compactList,
            stateManager: stateManager,
            internalModel: model,
            output: output
        )
    }
}
