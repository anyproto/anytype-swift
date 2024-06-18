import Foundation
import SwiftUI

struct GalleryWidgetView: View {
    
    let rows: [GalleryWidgetRowModel]?
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                if let rows {
                    ForEach(rows, id: \.objectId) { row in
                        GalleryWidgetRow(model: row)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
        .fixedSize(horizontal: false, vertical: true) // For equal height
    }
}
