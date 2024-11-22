import Foundation
import SwiftUI
import Services

struct MessageObjectAttachmentView: View {

    let icon: Icon
    let title: String
    let description: String
    
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
        .frame(height: 64)
        .frame(minWidth: 231)
        .background(Color.Background.secondary)
        .cornerRadius(18, style: .continuous)
    }
}

extension MessageObjectAttachmentView {
    init(details: MessageAttachmentDetails) {
        self = MessageObjectAttachmentView(
            icon: details.objectIconImage,
            title: details.title,
            description: details.objectType.name
        )
    }
}
