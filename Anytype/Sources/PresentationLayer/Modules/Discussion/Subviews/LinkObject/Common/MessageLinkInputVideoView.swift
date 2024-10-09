import SwiftUI
import Services

struct MessageLinkInputVideoView: View {
    
    let url: URL?
    let onTapRemove: () -> Void
    
    init(url: URL?, onTapRemove: @escaping () -> Void) {
        self.url = url
        self.onTapRemove = onTapRemove
    }
    
    var body: some View {
        MessageLinkVideoView(url: url)
            .frame(width: 72, height: 72)
            .messageLinkStyle()
            .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}

extension MessageLinkInputVideoView {
    init(details: MessageAttachmentDetails, onTapRemove: @escaping () -> Void) {
        self = MessageLinkInputVideoView(url: ContentUrlBuilder.fileUrl(fileId: details.id), onTapRemove: onTapRemove)
    }
}
