import Foundation
import SwiftUI

struct ListWidgetView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    let internalModel: any WidgetInternalViewModelProtocol
    let internalHeaderModel: (any WidgetDataviewInternalViewModelProtocol)?
    
    var body: some View {
        ListWidgetInternalView(
            data: data,
            style: style,
            internalModel: internalModel,
            internalHeaderModel: internalHeaderModel
        )
        .id(data.widgetBlockId + style.rawValue)
    }
}

private struct ListWidgetInternalView: View {
    
    let data: WidgetSubmoduleData
    
    @StateObject private var model: ListWidgetViewModel
    
    init(
        data: WidgetSubmoduleData,
        style: ListWidgetStyle,
        internalModel: some WidgetInternalViewModelProtocol,
        internalHeaderModel: (any WidgetDataviewInternalViewModelProtocol)?
    ) {
        self.data = data
        self._model = StateObject(
            wrappedValue: ListWidgetViewModel(
                widgetBlockId: data.widgetBlockId,
                widgetObject: data.widgetObject,
                style: style,
                internalModel: internalModel,
                internalHeaderModel: internalHeaderModel,
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
                bodyContent
            }
        )
    }
    
    private var bodyContent: some View {
        VStack(spacing: 0) {
            // TODO: Delete this header with galleryWidget toggle. Header implemented in View widget for set.
            ViewWidgetTabsView(items: model.headerItems)
            ListWidgetContentView(style: model.style, rows: model.rows)
        }
    }
    
    private var createTap: (() -> Void)? {
        return model.allowCreateObject ? {
           model.onCreateObjectTap()
       } : nil
    }
}
