import Foundation
import SwiftUI
import Services

struct MessageLinkObjectView: View {

    let icon: Icon
    let title: String
    let description: String
    let size: String?
    let onTapRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: icon)
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundColor(.Text.primary)
                HStack(spacing: 6) {
                    Text(description)
                        .anytypeStyle(.relation3Regular)
                        .foregroundColor(.Text.secondary)
                    if let size {
                        Circle()
                            .fill(Color.Text.secondary)
                            .frame(width: 3, height: 3)
                        Text(size)
                            .anytypeStyle(.relation3Regular)
                            .foregroundColor(.Text.secondary)
                    }
                }
            }
            .lineLimit(1)
            Spacer()
        }
        .padding(12)
        .frame(width: 216, height: 72)
        .background(Color.Background.secondary)
        .cornerRadius(12, style: .continuous)
        .outerBorder(12, color: .Shape.tertiary, lineWidth: 1)
        .shadow(color: .Additional.messageInputShadow, radius: 4)
        .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}

extension MessageLinkObjectView {
    init(details: MessageAttachmentDetails, onTapRemove: @escaping (MessageAttachmentDetails) -> Void) {
        let sizeInBytes = Int64(details.sizeInBytes ?? 0)
        let size = sizeInBytes > 0 ? ByteCountFormatter.fileFormatter.string(fromByteCount: sizeInBytes) : nil
        self = MessageLinkObjectView(
            icon: details.objectIconImage,
            title: details.title,
            description: details.description,
            size: size,
            onTapRemove: { onTapRemove(details) }
        )
    }
}
