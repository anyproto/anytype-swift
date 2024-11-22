import SwiftUI
import Services

struct MessageLinkedUploadedObject: View {
    
    let details: MessageAttachmentDetails
    let onTapObject: () -> Void
    let onTapRemove: () -> Void
    
    var body: some View {
        switch details.layoutValue {
        case .image:
            MessageLinkImageView(details: details, onTapRemove: { _ in
                onTapRemove()
            })
            .onTapGesture {
                onTapObject()
            }
        case .video:
            MessageInputVideoView(details: details, onTapRemove: onTapRemove)
                .onTapGesture {
                    onTapObject()
                }
        default:
            MessageLinkObjectView(details: details, onTapRemove: { _ in
                onTapRemove()
            })
            .onTapGesture {
                onTapObject()
            }
        }
    }
}
