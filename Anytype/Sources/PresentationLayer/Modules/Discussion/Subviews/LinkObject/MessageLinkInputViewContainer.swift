import Foundation
import SwiftUI
import Services

struct MessageLinkInputViewContainer: View {

    let objects: [ObjectDetails]
    let onTapObject: (ObjectDetails) -> Void
    let onTapRemove: (ObjectDetails) -> Void
    
    @State private var sizeWidth: CGFloat = 0
    
    var body: some View {
        if objects.isNotEmpty {
            content
        }
    }
    
    private var content: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(objects, id: \.id) { details in
                    MessageLinkObjectView(details: details, style: .input, onTapRemove: onTapRemove)
                        .frame(width: itemWidth)
                        .onTapGesture {
                            onTapObject(details)
                        }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .background(Color.Background.primary)
        .readSize { size in
            sizeWidth = size.width
        }
    }
    
    private var itemWidth: CGFloat {
        let width = sizeWidth - (objects.count > 1 ? 64 : 32)
        return max(width, 0)
    }
}

#Preview {
    MessageLinkInputViewContainer(
        objects: [
            ObjectDetails(id: "1", values: [
                BundledRelationKey.name.rawValue: "Title 1 123 123 123 123 123 123 123 123 12312 312 313 12312  3123 3",
                BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
                BundledRelationKey.iconEmoji.rawValue: "🦬"
            ]),
            ObjectDetails(id: "2", values: [
                BundledRelationKey.name.rawValue: "Title 1",
                BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
                BundledRelationKey.iconEmoji.rawValue: "🫏"
            ]),
            ObjectDetails(id: "3", values: [
                BundledRelationKey.name.rawValue: "Title 1",
                BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
                BundledRelationKey.iconEmoji.rawValue: "🦔"
            ])
        ],
        onTapObject: { _ in },
        onTapRemove: { _ in }
    )
    .border(Color.black)
}
