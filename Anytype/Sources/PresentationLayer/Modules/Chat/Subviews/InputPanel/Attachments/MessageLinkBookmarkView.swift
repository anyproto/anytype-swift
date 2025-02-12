import Foundation
import SwiftUI
import Services

struct MessageLinkBookmarkContainerView: View {

    let icon: Icon
    let title: String
    let description: String
    let onTapRemove: () -> Void
    
    var body: some View {
        MessageLinkBookmarkView(
            icon: icon,
            title: title,
            description: description
        )
        .messageLinkObjectStyle()
        .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}

struct MessageLinkBookmarkView: View {
    
    let icon: Icon
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                IconView(icon: icon)
                    .frame(width: 14, height: 14)
                Text(title)
                    .anytypeStyle(.caption1Regular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
                    .padding(.bottom, 5)
                Spacer()
            }
            Text(description)
                .anytypeStyle(.uxTitle2Medium)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
        }
        .padding(12)
    }
}

extension MessageLinkBookmarkContainerView {
    init(details: MessageAttachmentDetails, onTapRemove: @escaping () -> Void) {
        self = MessageLinkBookmarkContainerView(
            icon: details.objectIconImage,
            title: details.source ?? details.title,
            description: details.title,
            onTapRemove: onTapRemove
        )
    }
}
