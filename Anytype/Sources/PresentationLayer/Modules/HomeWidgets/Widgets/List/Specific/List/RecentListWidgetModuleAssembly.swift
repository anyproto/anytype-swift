import Foundation
import SwiftUI

final class RecentListWidgetModuleAssembly: HomeWidgetCommonAssemblyProtocol {
    
    private let type: RecentWidgetType
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(type: RecentWidgetType, widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.type = type
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
            widgetObject: widgetObject
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
