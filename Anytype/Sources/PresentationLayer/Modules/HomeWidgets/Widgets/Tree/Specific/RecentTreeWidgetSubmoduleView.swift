import Foundation
import SwiftUI

struct RecentTreeWidgetSubmoduleView: View {
    
    let widgetBlockId: String
    let widgetObject: BaseDocumentProtocol
    let stateManager: HomeWidgetsStateManagerProtocol
    let type: RecentWidgetType
    let output: CommonWidgetModuleOutput?
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        type: RecentWidgetType,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.stateManager = stateManager
        self.type = type
        self.output = output
    }
    
    var body: some View {
        TreeWidgetView(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            stateManager: stateManager,
            internalModel: RecentWidgetInternalViewModel(
                type: type,
                widgetBlockId: widgetBlockId,
                widgetObject: widgetObject
            ),
            output: output
        )
    }
}
