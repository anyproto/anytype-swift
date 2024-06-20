import Foundation
import SwiftUI

struct GalleryWidgetRowModel {
    let objectId: String
    let title: String
    let icon: Icon?
    let coverFit: Bool
    let cover: ObjectHeaderCoverType?
    let onTap: () -> Void
}

struct GalleryWidgetRow: View {
    
    let model: GalleryWidgetRowModel
    
    var body: some View {
        ZStack {
            Color.Background.primary
                .border(8, color: .Shape.primary)
            
            VStack(alignment: .leading, spacing: 0) {
                if let cover = model.cover {
                    SwiftUIObjectHeaderCoverView(objectCover: cover, size: CGSize(width: 136, height: 80), fitImage: model.coverFit)
                        .frame(height: 80)
                }
                ZStack(alignment: .leadingFirstTextBaseline) {
                    HStack {
                        Text(model.icon.isNotNil ? model.title.leftIndented : model.title)
                            .anytypeStyle(.caption1Medium)
                            .lineLimit(2)
                            .foregroundColor(Color.Text.primary)
                            .frame(maxHeight: .infinity, alignment: .top) // For equal height. Always height == 2 lines
                        Spacer()
                    }
                    if let icon = model.icon {
                        IconView(icon: icon)
                            .frame(width: 16, height: 16)
                            .alignmentGuide(.firstTextBaseline) { $0.height * 0.8 }
                    }
                }
                .padding(EdgeInsets(top: 9, leading: 12, bottom: 11, trailing: 12))
            }
            .frame(width: 136)
            .fixTappableArea()
            .onTapGesture {
                model.onTap()
            }
        }
        .cornerRadius(8, style: .continuous)
    }
}
