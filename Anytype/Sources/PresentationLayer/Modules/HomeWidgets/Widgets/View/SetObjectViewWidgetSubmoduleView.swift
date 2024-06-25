import Foundation
import SwiftUI

struct SetObjectViewWidgetSubmoduleView: View {
    let data: WidgetSubmoduleData
    
    var body: some View {
        SetObjectViewWidgetSubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

struct SetObjectViewWidgetSubmoduleInternalView: View {
    
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
                model.onOpenObjectTap()
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
        .onAppear {
            model.onAppear()
        }
    }
    
    private var bodyContent: some View {
        VStack(spacing: 0) {
            ViewWidgetTabsView(items: model.headerItems)
            if model.showUnsupportedBanner {
                SetUnsupportedView()
                    .padding(.vertical, 8)
            }
            rows
                .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var rows: some View {
        switch model.rows {
        case .list(let rows, let id):
            ListWidgetContentView(style: .list, rows: rows, emptyTitle: Loc.Widgets.Empty.title)
                .id(id)
        case .gallery(let rows, let id):
            GalleryWidgetView(rows: rows) {
                model.onOpenObjectTap()
            }
            .id(id)
        }
    }
}
