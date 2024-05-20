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
        
        let data =  WidgetSubmoduleData(widgetBlockId: widgetBlockId, widgetObject: widgetObject, stateManager: stateManager, output: output)
        let model = RecentWidgetInternalViewModel(data: data, type: type)
     
        return ListWidgetView(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            style: .list,
            stateManager: stateManager,
            internalModel: model,
            internalHeaderModel: nil,
            output: output
        ).eraseToAnyView()
    }
}
