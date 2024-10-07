import SwiftUI
import Services

struct MessageLinkedUploadedObject: View {
    
    let details: ObjectDetails
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
            if let url = ContentUrlBuilder.fileUrl(fileId: details.id) {
                MessageLinkLocalVideoView(url: url, onTapRemove: onTapRemove)
                    .onTapGesture {
                        onTapObject()
                    }
            }
        default:
            MessageLinkObjectView(details: details, style: .input, onTapRemove: { _ in
                onTapRemove()
            })
            .onTapGesture {
                onTapObject()
            }
        }
    }
}
