import Foundation
import SwiftUI

final class ObjectTreeWidgetModuleAssembly: HomeWidgetCommonAssemblyProtocol {
    
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
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
        
        let model = ObjectWidgetInternalViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            output: output
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
