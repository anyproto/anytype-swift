import Foundation
import SwiftUI

struct FavoriteTreeWidgetsubmoduleView: View {
    
    let widgetBlockId: String
    let widgetObject: BaseDocumentProtocol
    let stateManager: HomeWidgetsStateManagerProtocol
    let output: CommonWidgetModuleOutput?
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.stateManager = stateManager
        self.output = output
    }
    
    var body: some View {
        TreeWidgetView(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            stateManager: stateManager,
            internalModel: FavoriteWidgetInternalViewModel(
                widgetBlockId: widgetBlockId,
                widgetObject: widgetObject,
                output: output
            ),
            output: output
        )
    }
}
