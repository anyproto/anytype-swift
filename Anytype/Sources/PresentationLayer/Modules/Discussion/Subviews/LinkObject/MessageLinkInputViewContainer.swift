import Foundation
import SwiftUI
import Services

struct MessageLinkInputViewContainer: View {

    let objects: [DiscussionLinkedObject]
    let onTapObject: (DiscussionLinkedObject) -> Void
    let onTapRemove: (DiscussionLinkedObject) -> Void
    
    var body: some View {
        if objects.isNotEmpty {
            content
        }
    }
    
    private var content: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(objects) { object in
                    switch object {
                    case .uploadedObject(let details):
                        MessageLinkedUploadedObject(details: details) {
                            onTapObject(object)
                        } onTapRemove: {
                            onTapRemove(object)
                        }
                    case .localPhotosFile(let localFile):
                        MessageLinkedLocalPhotosFile(localFile: localFile) {
                            onTapObject(object)
                        } onTapRemove: {
                            onTapRemove(object)
                        }
                    case .localBinaryFile(let data):
                        MessageLinkedLocalFile(fileData: data) {
                            onTapObject(object)
                        } onTapRemove: {
                            onTapRemove(object)
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .background(Color.Background.primary)
    }
}

#Preview {
    MessageLinkInputViewContainer(
        objects: [
            .uploadedObject(
                ObjectDetails(id: "1", values: [
                    BundledRelationKey.name.rawValue: "Title 1 123 123 123 123 123 123 123 123 12312 312 313 12312  3123 3",
                    BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
                    BundledRelationKey.iconEmoji.rawValue: "🦬"
                ])
            ),
            .uploadedObject(
                ObjectDetails(id: "2", values: [
                    BundledRelationKey.name.rawValue: "Title 1",
                    BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
                    BundledRelationKey.iconEmoji.rawValue: "🫏"
                ])
            ),
            .uploadedObject(
                ObjectDetails(id: "3", values: [
                    BundledRelationKey.name.rawValue: "Title 1",
                    BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
                    BundledRelationKey.iconEmoji.rawValue: "🦔"
                ])
            )
        ],
        onTapObject: { _ in },
        onTapRemove: { _ in }
    )
    .border(Color.black)
}
