import Foundation
import SwiftUI
import Services

struct MessageBookmarkView: View {

    let icon: Icon
    let title: String
    let description: String
    let isYour: Bool
    
    var body: some View {
        MessageCommonBookmarkView(
            icon: icon,
            title: title,
            description: description,
            isYour: isYour
        )
        .frame(height: 64)
        .frame(minWidth: 231)
        .background(Color.Shape.transperentSecondary)
        .cornerRadius(12, style: .continuous)
    }
}

extension MessageBookmarkView {
    init(details: MessageAttachmentDetails, isYour: Bool) {
        self = MessageBookmarkView(
            icon: details.objectIconImage,
            title: details.source ?? details.title,
            description: details.title,
            isYour: isYour
        )
    }
}
