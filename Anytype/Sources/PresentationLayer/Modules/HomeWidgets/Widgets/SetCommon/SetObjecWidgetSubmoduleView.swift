import Foundation
import SwiftUI

struct SetObjecWidgetSubmoduleView: View {
    let data: WidgetSubmoduleData
    let style: SetObjecWidgetStyle
    
    var body: some View {
        SetObjectWidgetSubmoduleInternalView(data: data, style: style)
            .id(data.widgetBlockId + style.rawValue)
    }
}

private struct SetObjectWidgetSubmoduleInternalView: View {
    
    private let data: WidgetSubmoduleData
    @StateObject private var model: SetObjectWidgetInternalViewModel
    
    init(data: WidgetSubmoduleData, style: SetObjecWidgetStyle) {
        self.data = data
        self._model = StateObject(wrappedValue: SetObjectWidgetInternalViewModel(data: data, style: style))
    }
    
    var body: some View {
        WidgetContainerView(
            widgetBlockId: data.widgetBlockId,
            widgetObject: data.widgetObject,
            homeState: data.homeState,
            name: model.name,
            dragId: model.dragId,
            onCreateObjectTap: createTap,
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
        .task {
            await model.onAppear()
        }
    }
    
    private var bodyContent: some View {
        VStack(spacing: 0) {
            ViewWidgetTabsView(items: model.headerItems)
            if model.showUnsupportedBanner {
                SetUnsupportedView()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
            }
            rows
                .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var rows: some View {
        switch model.rows {
        case .list(let rows, let id):
            ListWidgetContentView(style: .list, rows: rows)
                .id(id)
        case .compactList(let rows, let id):
            ListWidgetContentView(style: .compactList, rows: rows)
                .id(id)
        case .gallery(let rows, let id):
            GalleryWidgetView(
                rows: rows,
                onShowAllObjects: {
                    model.onOpenObjectTap()
                }
            )
            .id(id)
        }
    }
    
    private var createTap: (() -> Void)? {
        return model.allowCreateObject ? {
           model.onCreateObjectTap()
       } : nil
    }
}
