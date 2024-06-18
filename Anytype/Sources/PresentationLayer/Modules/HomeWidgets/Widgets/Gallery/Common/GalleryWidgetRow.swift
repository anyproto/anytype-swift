import Foundation
import SwiftUI

struct GalleryWidgetRowModel {
    let objectId: String
    let title: String
    let icon: Icon?
    let onTap: () -> Void
}

struct GalleryWidgetRow: View {
    
    let model: GalleryWidgetRowModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leadingFirstTextBaseline) {
                if let icon = model.icon {
                    IconView(icon: icon)
                        .frame(width: 16, height: 16)
                        .alignmentGuide(.firstTextBaseline) { $0.height * 0.8 }
                }
                HStack {
                    Text(model.icon.isNotNil ? model.title.leftIndented : model.title)
                        .anytypeStyle(.caption1Medium)
                        .lineLimit(2)
                        .foregroundColor(Color.Text.primary)
                        .frame(maxHeight: .infinity, alignment: .top) // For equal height. Always height == 2 lines
                    Spacer()
                }
            }
            .padding(EdgeInsets(top: 9, leading: 12, bottom: 11, trailing: 12))
        }
        .frame(width: 136)
        .background(Color.Background.primary)
        .cornerRadius(8, style: .continuous)
        .border(8, color: .Shape.primary)
    }
}
