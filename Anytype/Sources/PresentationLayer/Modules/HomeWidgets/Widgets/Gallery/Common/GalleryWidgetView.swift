import Foundation
import SwiftUI

struct GalleryWidgetView: View {
    
    let rows: [GalleryWidgetRowModel]?
    let onShowAllObjects: () -> Void
    
    var body: some View {
        WidgetContainerWithEmptyState(showEmpty: (rows?.isEmpty ?? false)) {
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                if let rows {
                    ForEach(rows, id: \.objectId) { row in
                        GalleryWidgetRow(model: row)
                    }
                    GalleryWidgetShowAllView(onTap: onShowAllObjects)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 8)
        }
        .scrollIndicators(.hidden)
        .fixedSize(horizontal: false, vertical: true) // For equal height
    }
}
