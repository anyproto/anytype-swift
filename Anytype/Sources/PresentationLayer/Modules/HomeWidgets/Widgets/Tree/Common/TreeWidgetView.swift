import Foundation
import SwiftUI

struct TreeWidgetView: View {
    
    let data: WidgetSubmoduleData
    
    @StateObject private var model: TreeWidgetViewModel
    
    init(
        data: WidgetSubmoduleData,
        internalModel: some WidgetInternalViewModelProtocol
    ) {
        self.data = data
        self._model = StateObject(
            wrappedValue: TreeWidgetViewModel(
                widgetBlockId: data.widgetBlockId,
                widgetObject: data.widgetObject,
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
            icon: model.icon,
            dragId: model.dragId,
            onCreateObjectTap: createTap,
            onHeaderTap: {
                model.onHeaderTap()
            },
            output: data.output,
            content: {
                content
            }
        )
        .task(priority: .high) {
            await model.startTreeSubscription()
        }
    }
    
    var content: some View {
        WidgetContainerWithEmptyState(
            showEmpty: (model.rows?.isEmpty ?? false)
        ) {
            if let rows = model.rows {
                VStack(spacing: 0) {
                    ForEach(rows, id: \.rowId) {
                        TreeWidgetRowView(model: $0, showDivider: $0.rowId != rows.last?.rowId)
                    }
                    if model.availableMore {
                        WidgetSeeAllRow {
                            model.onSeeAllTap()
                        }
                    }
                    Spacer.fixedHeight(8)
                }
            }
        }
    }
    
    private var createTap: (() -> Void)? {
        return model.allowCreateObject ? {
           model.onCreateObjectTap()
       } : nil
    }
}
