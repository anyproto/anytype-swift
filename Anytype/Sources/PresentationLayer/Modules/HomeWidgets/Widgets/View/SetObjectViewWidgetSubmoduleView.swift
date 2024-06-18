import Foundation
import SwiftUI

struct SetObjectViewWidgetSubmoduleView: View {
    
    private let data: WidgetSubmoduleData
    @StateObject private var model: SetObjectWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData) {
        self.data = data
        self._model = StateObject(wrappedValue: SetObjectWidgetInternalViewModel(data: data))
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
                bodyContent
            }
        )
        .task {
            await model.startPermissionsPublisher()
        }
        .task {
            await model.startInfoPublisher()
        }
        .task {
            await model.startTargetDetailsPublisher()
        }
        .task(id: model.contentTaskId) {
            await model.startContentSubscription()
        }
    }
    
    private var bodyContent: some View {
        VStack(spacing: 0) {
            ViewWidgetTabsView(items: model.headerItems)
            // TODO: Support different views
            ListWidgetContentView(style: .list, rows: model.rows, emptyTitle: Loc.Widgets.Empty.title)
        }
    }
}
