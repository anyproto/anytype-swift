import Foundation
import SwiftUI
import AnytypeCore

struct GalleryWidgetView: View {
    
    let rows: [GalleryWidgetRowModel]?
    let showAllObjects: Bool
    let onShowAllObjects: () -> Void
    
    @State private var showAllButtonInWidgets = FeatureFlags.showAllButtonInWidgets
    
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
                    if showAllButtonInWidgets, showAllObjects {
                        GalleryWidgetShowAllView(onTap: onShowAllObjects)
                    }
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
