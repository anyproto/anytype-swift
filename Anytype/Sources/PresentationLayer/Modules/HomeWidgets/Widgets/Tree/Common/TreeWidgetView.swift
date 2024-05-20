import Foundation
import SwiftUI

struct TreeWidgetView: View {
    
    let widgetBlockId: String
    let widgetObject: BaseDocumentProtocol
    let stateManager: HomeWidgetsStateManagerProtocol
    let output: CommonWidgetModuleOutput?
    
    @StateObject private var model: TreeWidgetViewModel
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        internalModel: WidgetInternalViewModelProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.stateManager = stateManager
        self.output = output
        self._model = StateObject(
            wrappedValue: TreeWidgetViewModel(
                widgetBlockId: widgetBlockId,
                internalModel: internalModel,
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
            content: content
        )
    }
    
    var content: some View {
        ZStack {
            if let rows = model.rows {
                VStack(spacing: 0) {
                    WidgetEmptyView(title: Loc.Widgets.Empty.title)
                        .frame(height: rows.isEmpty ? 72 : 0)
                    Spacer.fixedHeight(8)
                }
                .opacity(rows.isEmpty ? 1 : 0)
                VStack(spacing: 0) {
                    ForEach(rows, id: \.rowId) {
                        TreeWidgetRowView(model: $0, showDivider: $0.rowId != rows.last?.rowId)
                    }
                    Spacer.fixedHeight(8)
                }
                .opacity(rows.isEmpty ? 0 : 1)
            }
        }
    }
}
