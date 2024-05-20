import Foundation
import SwiftUI

struct ListWidgetView: View {
    
    let widgetBlockId: String
    let widgetObject: BaseDocumentProtocol
    let style: ListWidgetStyle
    let stateManager: HomeWidgetsStateManagerProtocol
    let internalModel: WidgetInternalViewModelProtocol
    let internalHeaderModel: WidgetDataviewInternalViewModelProtocol?
    let output: CommonWidgetModuleOutput?
    
    var body: some View {
        ListWidgetInternalView(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            style: style,
            stateManager: stateManager,
            internalModel: internalModel,
            internalHeaderModel: internalHeaderModel,
            output: output
        )
        .id(widgetBlockId + style.rawValue)
    }
}

private struct ListWidgetInternalView: View {
    
    let widgetBlockId: String
    let widgetObject: BaseDocumentProtocol
    let stateManager: HomeWidgetsStateManagerProtocol
    let output: CommonWidgetModuleOutput?
    
    @StateObject private var model: ListWidgetViewModel
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        style: ListWidgetStyle,
        stateManager: HomeWidgetsStateManagerProtocol,
        internalModel: WidgetInternalViewModelProtocol,
        internalHeaderModel: WidgetDataviewInternalViewModelProtocol?,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.stateManager = stateManager
        self.output = output
        self._model = StateObject(
            wrappedValue: ListWidgetViewModel(
                widgetBlockId: widgetBlockId,
                widgetObject: widgetObject,
                style: style,
                internalModel: internalModel,
                internalHeaderModel: internalHeaderModel,
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
            content: bodyContent
        )
    }
    
    private var bodyContent: some View {
        VStack(spacing: 0) {
            header
            content
        }
    }
    
    private var header: some View {
        Group {
            if let headerItems = model.headerItems, headerItems.isNotEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(headerItems, id: \.dataviewId) {
                            ListWidgetHeaderItem(model: $0)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                }
            }
        }
    }
    
    private var content: some View {
        ZStack {
            if let rows = model.rows {
                VStack(spacing: 0) {
                    WidgetEmptyView(title: model.emptyTitle)
                        .frame(height: 72)
                    Spacer.fixedHeight(8)
                }
                .opacity(rows.isEmpty ? 1 : 0)
                VStack(spacing: 0) {
                    ForEach(rows) {
                        rowView(row: $0, showDivider: $0.id != rows.last?.id)
                    }
                    Spacer.fixedHeight(8)
                }
                .opacity(rows.isEmpty ? 0 : 1)
            }
        }
        // This fixes the tap area for header in bottom side
        .fixTappableArea()
    }
    
    @ViewBuilder
    private func rowView(row: ListWidgetRowModel, showDivider: Bool) -> some View {
        switch model.style {
        case .compactList:
            ListWidgetCompactRow(model: row, showDivider: showDivider)
        case .list:
            ListWidgetRow(model: row, showDivider: showDivider)
        }
    }
}
