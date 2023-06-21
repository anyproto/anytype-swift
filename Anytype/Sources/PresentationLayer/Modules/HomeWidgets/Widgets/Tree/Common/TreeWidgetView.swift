import Foundation
import SwiftUI

struct TreeWidgetView: View {
    
    @ObservedObject var model: TreeWidgetViewModel
    
    var body: some View {
        ZStack {
            if let rows = model.rows {
                VStack(spacing: 0) {
                    WidgetEmptyView(title: Loc.Widgets.Empty.title)
                        .frame(height: rows.isEmpty ? 72 : 0)
                    Spacer.fixedHeight(8)
                }
                .opacity(rows.isEmpty ? 1 : 0)
                VStack(spacing: 0) {
                    ForEach(rows, id: \.rowId) {
                        TreeWidgetRowView(model: $0, showDivider: $0.rowId != rows.last?.rowId)
                    }
                    Spacer.fixedHeight(8)
                }
                .opacity(rows.isEmpty ? 0 : 1)
            }
        }
    }
}
