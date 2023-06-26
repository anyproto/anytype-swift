import Foundation
import SwiftUI

struct ListWidgetView: View {
    
    @ObservedObject var model: ListWidgetViewModel
    
    var body: some View {
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
                }
                .frame(height: 40)
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
