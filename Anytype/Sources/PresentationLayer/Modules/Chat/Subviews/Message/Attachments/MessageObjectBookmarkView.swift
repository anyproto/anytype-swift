import Foundation
import SwiftUI
import Services

struct MessageObjectBookmarkView: View {

    let icon: Icon
    let title: String
    let description: String
    
    var body: some View {
        MessageLinkBookmarkView(
            icon: icon,
            title: title,
            description: description
        )
        .frame(height: 64)
        .frame(minWidth: 231)
        .background(Color.Background.primary)
        .cornerRadius(12, style: .continuous)
        .border(12, color: Color.Shape.transperentSecondary)
    }
}

extension MessageObjectBookmarkView {
    init(details: MessageAttachmentDetails) {
        self = MessageObjectBookmarkView(
            icon: details.objectIconImage,
            title: details.source ?? details.title,
            description: details.title
        )
    }
}
