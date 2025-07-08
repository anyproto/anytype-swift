import Foundation
import SwiftUI
import Services

struct MessageAttachmentView: View {

    let icon: Icon
    let title: String
    let description: String
    let position: MessageHorizontalPosition
    let size: String?
    let syncStatus: SyncStatus?
    let syncError: SyncError?
    
    var body: some View {
        MessageCommonObjectView(
            icon: icon,
            title: title,
            description: description,
            style: position.isRight ? .messageYour : .messageOther,
            size: size,
            syncStatus: syncStatus,
            syncError: syncError
        )
        .frame(height: 64)
        .frame(minWidth: 231)
        .background(Color.Shape.transperentSecondary)
        .cornerRadius(12, style: .continuous)
    }
}

extension MessageAttachmentView {
    init(details: MessageAttachmentDetails, position: MessageHorizontalPosition) {
        let sizeInBytes = Int64(details.sizeInBytes ?? 0)
        let size = sizeInBytes > 0 ? ByteCountFormatter.fileFormatter.string(fromByteCount: sizeInBytes) : nil
        self = MessageAttachmentView(
            icon: details.objectIconImage,
            title: details.title,
            description: details.description,
            position: position,
            size: size,
            syncStatus: details.syncStatus,
            syncError: details.syncError
        )
    }
}
