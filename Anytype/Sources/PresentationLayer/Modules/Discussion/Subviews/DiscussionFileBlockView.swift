import Foundation
import SwiftUI
import Services

struct DiscussionFileBlockView: View {

    let details: MessageAttachmentDetails

    var body: some View {
        MessageCommonObjectView(
            icon: details.objectIconImage,
            title: details.title,
            description: details.description,
            style: .messageOther,
            size: details.sizeInBytes.map { ByteCountFormatter.fileFormatter.string(fromByteCount: Int64($0)) },
            syncStatus: details.syncStatus,
            syncError: details.syncError
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Shape.transparentSecondary)
        .clipShape(.rect(cornerRadius: 12))
    }
}
