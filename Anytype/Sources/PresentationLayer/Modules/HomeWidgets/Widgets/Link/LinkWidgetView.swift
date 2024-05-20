import Foundation
import SwiftUI

struct LinkWidgetView: View {
    
    let widgetBlockId: String
    let widgetObject: BaseDocumentProtocol
    let stateManager: HomeWidgetsStateManagerProtocol
    let output: CommonWidgetModuleOutput?
    
    @StateObject private var model: LinkWidgetViewModel
    
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
        self._model = StateObject(
            wrappedValue: LinkWidgetViewModel(
                widgetBlockId: widgetBlockId,
                widgetObject: widgetObject,
                output: output
            )
        )
    }
    
    var body: some View {
        WidgetContainerView(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            stateManager: stateManager,
            contentModel: model,
            output: output,
            content: EmptyView()
        )
    }
}
