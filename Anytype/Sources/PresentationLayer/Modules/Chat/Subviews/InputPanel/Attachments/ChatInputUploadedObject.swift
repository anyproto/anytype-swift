import SwiftUI
import Services

struct ChatInputUploadedObject: View {
    
    let details: MessageAttachmentDetails
    let onTapObject: () -> Void
    let onTapRemove: () -> Void
    
    var body: some View {
        switch details.resolvedLayoutValue {
        case .image:
            ChatInputImageView(details: details, onTapRemove: { _ in
                onTapRemove()
            })
            .onTapGesture {
                onTapObject()
            }
        case .video:
            ChatInputVideoView(details: details, onTapRemove: onTapRemove)
                .onTapGesture {
                    onTapObject()
                }
        case .bookmark:
            ChatInputBookmarkView(details: details, onTapRemove: onTapRemove)
                .onTapGesture {
                    onTapObject()
                }
        default:
            ChatInputObjectView(details: details, onTapRemove: { _ in
                onTapRemove()
            })
            .onTapGesture {
                onTapObject()
            }
        }
    }
}
