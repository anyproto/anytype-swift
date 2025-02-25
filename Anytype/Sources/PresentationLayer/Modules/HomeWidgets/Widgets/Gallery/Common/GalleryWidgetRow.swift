import Foundation
import SwiftUI

struct GalleryWidgetRowModel {
    let objectId: String
    let title: String?
    let icon: Icon?
    let cover: ObjectHeaderCoverType?
    let onTap: @MainActor () -> Void
    
    var shouldIncreaseCoverHeight: Bool {
        cover.isNotNil && icon.isNil && title.isNil
    }
}

struct GalleryWidgetRow: View {
    
    let model: GalleryWidgetRowModel
    
    var body: some View {
        ZStack {
            Color.clear
                .border(8, color: .Shape.transperentPrimary)
            
            VStack(alignment: .leading, spacing: 0) {
                if let cover = model.cover {
                    ObjectHeaderCoverView(objectCover: cover, fitImage: false)
                        .frame(height: model.shouldIncreaseCoverHeight ? 136 : 80)
                }
                if model.icon.isNotNil || model.title.isNotNil {
                    info
                }
            }
            .frame(width: 136)
            .fixTappableArea()
            .onTapGesture {
                model.onTap()
            }
        }
        .cornerRadius(8, style: .continuous)
        .id(model.objectId)
    }
    
    private var info: some View {
        ZStack(alignment: model.icon.isNotNil ? .leadingFirstTextBaseline : .leading) {
            if let title = model.title {
                HStack {
                    Text(model.icon.isNotNil ? title.leftIndented : title)
                        .anytypeStyle(.caption1Medium)
                        .lineLimit(2)
                        .foregroundColor(Color.Text.primary)
                        .frame(maxHeight: .infinity, alignment: .top) // For equal height. Always height == 2 lines
                    Spacer()
                }
            }
            if let icon = model.icon {
                IconView(icon: icon)
                    .frame(width: 16, height: 16)
                    .alignmentGuide(.firstTextBaseline) { $0.height * 0.8 }
            }
        }
        .padding(EdgeInsets(top: 9, leading: 12, bottom: 11, trailing: 12))
    }
}
