import Foundation
import SwiftUI
import Services

struct MessageLinkInputViewContainer: View {

    let objects: [ObjectDetails]
    let onTapRemove: (ObjectDetails) -> Void
    
    @State private var itemWidth: CGFloat = 0
    
    var body: some View {
        if objects.isNotEmpty {
            content
        }
    }
    
    private var content: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(objects, id: \.id) {
                    MessageLinkObjectView(details: $0, style: .input, onTapRemove: onTapRemove)
                        .frame(width: itemWidth)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .background(Color.Background.primary)
        .readSize { size in
            itemWidth = size.width - 32
        }
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
        onTapRemove: { _ in }
    )
    .border(Color.black)
}
