import Foundation
import SwiftUI

struct TreeWidgetView: View {
    
    let data: WidgetSubmoduleData
    
    @StateObject private var model: TreeWidgetViewModel
    
    init(
        data: WidgetSubmoduleData,
        internalModel: WidgetInternalViewModelProtocol
    ) {
        self.data = data
        self._model = StateObject(
            wrappedValue: TreeWidgetViewModel(
                widgetBlockId: data.widgetBlockId,
                internalModel: internalModel,
                output: data.output
            )
        )
    }
    
    var body: some View {
        WidgetContainerView(
            widgetBlockId: data.widgetBlockId,
            widgetObject: data.widgetObject,
            homeState: data.homeState,
            name: model.name,
            dragId: model.dragId,
            onCreateObjectTap: model.allowCreateObject ? {
                model.onCreateObjectTap()
            } : nil,
            onHeaderTap: {
                model.onHeaderTap()
            },
            output: data.output,
            content: {
                content
            }
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
                .hidden(rows.isNotEmpty)
                VStack(spacing: 0) {
                    ForEach(rows, id: \.rowId) {
                        TreeWidgetRowView(model: $0, showDivider: $0.rowId != rows.last?.rowId)
                    }
                    Spacer.fixedHeight(8)
                }
                .hidden(rows.isEmpty)
            }
        }
    }
}
