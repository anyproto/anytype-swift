import Foundation
import SwiftUI
import Services

struct ChatInputObjectView: View {

    let icon: Icon
    let title: String
    let description: String
    let size: String?
    let onTapRemove: () -> Void
    
    var body: some View {
        MessageCommonObjectView(
            icon: icon,
            title: title,
            description: description,
            isYour: true,
            size: size
        )
        .messageLinkObjectStyle()
        .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}

extension ChatInputObjectView {
    init(details: MessageAttachmentDetails, onTapRemove: @escaping (MessageAttachmentDetails) -> Void) {
        let sizeInBytes = Int64(details.sizeInBytes ?? 0)
        let size = sizeInBytes > 0 ? ByteCountFormatter.fileFormatter.string(fromByteCount: sizeInBytes) : nil
        self = ChatInputObjectView(
            icon: details.objectIconImage,
            title: details.title,
            description: details.description,
            size: size,
            onTapRemove: { onTapRemove(details) }
        )
    }
}
