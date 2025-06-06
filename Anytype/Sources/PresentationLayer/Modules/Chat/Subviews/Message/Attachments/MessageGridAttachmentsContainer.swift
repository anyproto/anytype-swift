import Foundation
import SwiftUI
import Services

struct MessageGridAttachmentsContainer: View {

    let objects: [MessageAttachmentDetails]
    let spacing: CGFloat
    let onTapObject: (MessageAttachmentDetails) -> Void
    
    init(
        objects: [MessageAttachmentDetails],
        spacing: CGFloat,
        onTapObject: @escaping (MessageAttachmentDetails) -> Void
    ) {
        self.objects = objects
        self.spacing = spacing
        self.onTapObject = onTapObject
    }
    
    var body: some View {
        MessageGridAttachmentsLayout(spacing: spacing) {
            ForEach(objects, id:\.id) { object in
                Button {
                    onTapObject(object)
                } label: {
                    switch object.resolvedLayoutValue {
                    case .video:
                        MessageVideoView(details: object)
                    default: // image and other types (for bugs)
                        MessageImageView(imageId: object.id)
                    }
                }
                .cornerRadius(4)
            }
        }
        .cornerRadius(12)
    }
}
