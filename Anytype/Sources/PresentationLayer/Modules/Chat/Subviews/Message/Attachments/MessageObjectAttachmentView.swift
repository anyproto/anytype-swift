import Foundation
import SwiftUI
import Services

struct MessageObjectAttachmentView: View {

    let icon: Icon
    let title: String
    let description: String
    let size: String?
    
    var body: some View {
        MessageLinkObjectView(
            icon: icon,
            title: title,
            description: description,
            size: size
        )
        .frame(height: 64)
        .frame(minWidth: 231)
        .background(Color.Background.secondary)
        .cornerRadius(18, style: .continuous)
    }
}

extension MessageObjectAttachmentView {
    init(details: MessageAttachmentDetails) {
        let sizeInBytes = Int64(details.sizeInBytes ?? 0)
        let size = sizeInBytes > 0 ? ByteCountFormatter.fileFormatter.string(fromByteCount: sizeInBytes) : nil
        self = MessageObjectAttachmentView(
            icon: details.objectIconImage,
            title: details.title,
            description: details.description,
            size: size
        )
    }
}
