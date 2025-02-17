import Foundation
import SwiftUI
import Services

struct MessageAttachmentView: View {

    let icon: Icon
    let title: String
    let description: String
    let isYour: Bool
    let size: String?
    
    var body: some View {
        MessageCommonObjectView(
            icon: icon,
            title: title,
            description: description,
            isYour: isYour,
            size: size
        )
        .frame(height: 64)
        .frame(minWidth: 231)
        .background(Color.Shape.transperentSecondary)
        .cornerRadius(12, style: .continuous)
    }
}

extension MessageAttachmentView {
    init(details: MessageAttachmentDetails, isYour: Bool) {
        let sizeInBytes = Int64(details.sizeInBytes ?? 0)
        let size = sizeInBytes > 0 ? ByteCountFormatter.fileFormatter.string(fromByteCount: sizeInBytes) : nil
        self = MessageAttachmentView(
            icon: details.objectIconImage,
            title: details.title,
            description: details.description,
            isYour: isYour,
            size: size
        )
    }
}
