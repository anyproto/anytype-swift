import Foundation
import SwiftUI
import Services

struct MessageLinkObjectView: View {

    let icon: Icon
    let title: String
    let description: String
    let style: MessageLinkObjectViewStyle
    let onTapRemove: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: icon)
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundColor(.Text.primary)
                Text(description)
                    .anytypeStyle(.relation3Regular)
                    .foregroundColor(.Text.secondary)
            }
            .lineLimit(1)
            Spacer()
        }
        .padding(12)
        .frame(width: 216, height: 72)
        .background(Color.Background.secondary)
        .cornerRadius(12, style: .continuous)
        .outerBorder(12, color: style.config.borderColor, lineWidth: 1)
        .shadow(color: style.config.shadowColor, radius: 4)
        .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}

extension MessageLinkObjectView {
    init(details: MessageAttachmentDetails, style: MessageLinkObjectViewStyle, onTapRemove: ((MessageAttachmentDetails) -> Void)? = nil) {
        self = MessageLinkObjectView(
            icon: details.objectIconImage,
            title: details.title,
            description: details.objectType.name,
            style: style,
            onTapRemove: onTapRemove.map { c in { c(details) } }
        )
    }
}

#Preview {
    MessageLinkObjectView(
        icon: Icon.object(.placeholder("A")),
        title: "Object Name",
        description: "Object Type",
        style: .input,
        onTapRemove: {}
    )
    .padding(16)
    .border(Color.black)
}
