import Foundation
import SwiftUI
import Services

struct ChatInputImageView: View {

    let imageId: String
    let onTapRemove: (() -> Void)?
    
    var body: some View {
        ImageIdIconView(imageId: imageId)
            .frame(width: 72, height: 72)
            .messageLinkStyle()
            .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}

extension ChatInputImageView {
    init(details: MessageAttachmentDetails, onTapRemove: ((MessageAttachmentDetails) -> Void)? = nil) {
        self = ChatInputImageView(
            imageId: details.id,
            onTapRemove: onTapRemove.map { c in { c(details) } }
        )
    }
}

