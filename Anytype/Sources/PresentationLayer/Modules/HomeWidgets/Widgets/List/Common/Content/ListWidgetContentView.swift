import Foundation
import SwiftUI

struct ListWidgetContentView: View {
    
    let style: ListWidgetStyle
    let rows: [ListWidgetRowModel]?
    
    var body: some View {
        WidgetContainerWithEmptyState(showEmpty: rows?.isEmpty ?? false) {
            content
        }
        // This fixes the tap area for header in bottom side
        .fixTappableArea()
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            if let rows {
                ForEach(rows) {
                    rowView(row: $0, showDivider: $0.id != rows.last?.id)
                }
                Spacer.fixedHeight(8)
            }
        }
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func rowView(row: ListWidgetRowModel, showDivider: Bool) -> some View {
        switch style {
        case .compactList:
            ListWidgetCompactRow(model: row, showDivider: showDivider)
        case .list:
            ListWidgetRow(model: row, showDivider: showDivider)
        }
    }
}
