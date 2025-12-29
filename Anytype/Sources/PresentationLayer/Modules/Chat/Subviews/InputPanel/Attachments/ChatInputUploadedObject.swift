import SwiftUI
import Services

struct ChatInputUploadedObject: View {
    
    let details: MessageAttachmentDetails
    let onTapObject: () -> Void
    let onTapRemove: () -> Void
    
    var body: some View {
        switch details.resolvedLayoutValue {
        case .image:
            Button {
                onTapObject()
            } label: {
                ChatInputImageView(details: details, onTapRemove: { _ in
                    onTapRemove()
                })
            }
            .buttonStyle(.plain)
        case .video:
            Button {
                onTapObject()
            } label: {
                ChatInputVideoView(details: details, onTapRemove: onTapRemove)
            }
            .buttonStyle(.plain)
        case .bookmark:
            Button {
                onTapObject()
            } label: {
                ChatInputBookmarkView(details: details, onTapRemove: onTapRemove)
            }
            .buttonStyle(.plain)
        default:
            Button {
                onTapObject()
            } label: {
                ChatInputObjectView(details: details, onTapRemove: { _ in
                    onTapRemove()
                })
            }
            .buttonStyle(.plain)
        }
    }
}
