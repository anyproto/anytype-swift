import Foundation
import SwiftUI

final class RecentCompactListWidgetModuleAssembly: HomeWidgetCommonAssemblyProtocol {
    
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
            data: data,
            style: .compactList,
            internalModel: model,
            internalHeaderModel: nil
        ).eraseToAnyView()
    }
}
