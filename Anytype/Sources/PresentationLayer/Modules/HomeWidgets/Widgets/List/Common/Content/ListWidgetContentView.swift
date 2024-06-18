import Foundation
import SwiftUI

struct ListWidgetContentView: View {
    
    let style: ListWidgetStyle
    let rows: [ListWidgetRowModel]?
    let emptyTitle: String
    
    var body: some View {
        ZStack {
            if let rows = rows {
                if rows.isEmpty {
                    VStack(spacing: 0) {
                        WidgetEmptyView(title: emptyTitle)
                            .frame(height: 72)
                        Spacer.fixedHeight(8)
                    }
                    .transition(.opacity)
                }
                else {
                    VStack(spacing: 0) {
                        ForEach(rows) {
                            rowView(row: $0, showDivider: $0.id != rows.last?.id)
                        }
                        Spacer.fixedHeight(8)
                    }
                    .transition(.opacity)
                }
            }
        }
        // This fixes the tap area for header in bottom side
        .fixTappableArea()
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
