import Foundation
import SwiftUI
import Services

struct MessageBookmarkView: View {

    let icon: Icon
    let title: String
    let description: String
    let position: MessageHorizontalPosition
    
    var body: some View {
//        MessageCommonBookmarkView(
//            icon: icon,
//            title: title,
//            description: description,
//            style: position.isRight ? .messageYour : .messageOther
//        )
//        .frame(height: 64)
        EmptyView()
        .frame(minWidth: 231)
//        .background(Color.Shape.transperentSecondary)
//        .cornerRadius(12, style: .continuous)
    }
}

extension MessageBookmarkView {
    init(details: MessageAttachmentDetails, position: MessageHorizontalPosition) {
        self = MessageBookmarkView(
            icon: details.objectIconImage,
            title: details.source ?? details.title,
            description: details.title,
            position: position
        )
    }
}
