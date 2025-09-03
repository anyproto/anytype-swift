import SwiftUI
import Services

struct ChatInputVideoView: View {
    
    let url: URL?
    let onTapRemove: () -> Void
    
    init(url: URL?, onTapRemove: @escaping () -> Void) {
        self.url = url
        self.onTapRemove = onTapRemove
    }
    
    var body: some View {
        EmptyView()
//        MessageVideoView(url: url)
//            .frame(width: 72, height: 72)
//            .messageLinkStyle()
//            .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}

extension ChatInputVideoView {
    init(details: MessageAttachmentDetails, onTapRemove: @escaping () -> Void) {
        self = ChatInputVideoView(url: ContentUrlBuilder.fileUrl(fileId: details.id), onTapRemove: onTapRemove)
    }
}
