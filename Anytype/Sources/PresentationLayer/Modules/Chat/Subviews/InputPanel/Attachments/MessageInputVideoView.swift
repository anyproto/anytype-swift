import SwiftUI
import Services

struct MessageInputVideoView: View {
    
    let url: URL?
    let onTapRemove: () -> Void
    
    init(url: URL?, onTapRemove: @escaping () -> Void) {
        self.url = url
        self.onTapRemove = onTapRemove
    }
    
    var body: some View {
        MessageVideoView(url: url)
            .frame(width: 72, height: 72)
            .messageLinkStyle()
            .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}

extension MessageInputVideoView {
    init(details: MessageAttachmentDetails, onTapRemove: @escaping () -> Void) {
        self = MessageInputVideoView(url: ContentUrlBuilder.fileUrl(fileId: details.id), onTapRemove: onTapRemove)
    }
}
