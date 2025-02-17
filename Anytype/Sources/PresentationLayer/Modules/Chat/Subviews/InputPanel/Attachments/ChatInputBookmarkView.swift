import Foundation
import SwiftUI
import Services

struct ChatInputBookmarkView: View {

    let icon: Icon
    let title: String
    let description: String
    let onTapRemove: () -> Void
    
    var body: some View {
        MessageCommonBookmarkView(
            icon: icon,
            title: title,
            description: description,
            style: .chatInput
        )
        .messageLinkObjectStyle()
        .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}

extension ChatInputBookmarkView {
    init(details: MessageAttachmentDetails, onTapRemove: @escaping () -> Void) {
        self = ChatInputBookmarkView(
            icon: details.objectIconImage,
            title: details.source ?? details.title,
            description: details.title,
            onTapRemove: onTapRemove
        )
    }
}
