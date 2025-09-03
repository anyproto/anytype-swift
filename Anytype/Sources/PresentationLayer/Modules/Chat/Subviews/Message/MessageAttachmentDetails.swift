import SwiftUI
import Services

struct MessageAttachmentDetails: Equatable, Identifiable, Hashable {
    let messageId: String
    let id: String
    let title: String
    let description: String
    let sizeInBytes: Int?
    let resolvedLayoutValue: DetailsLayout
    let objectIconImage: Icon
    let source: String?
    let syncStatus: SyncStatus?
    let syncError: SyncError?
    let downloadingState: Bool
    let style: MessageAttachmentStyle
}

extension MessageAttachmentDetails {
    init(messageId: String, details: ObjectDetails, style: MessageAttachmentStyle) {
        let source = details.source?.url.host() ?? details.source?.absoluteString
        self = MessageAttachmentDetails(
            messageId: messageId,
            id: details.id,
            title: details.title,
            description: details.objectType.displayName,
            sizeInBytes: details.sizeInBytes,
            resolvedLayoutValue: details.resolvedLayoutValue,
            objectIconImage: details.objectIconImage,
            source: source,
            syncStatus: details.syncStatusValue,
            syncError: details.syncErrorValue,
            downloadingState: false,
            style: style
        )
    }
    
    static func placeholder(messageId: String, tagetId: String, style: MessageAttachmentStyle) -> Self {
        MessageAttachmentDetails(
            messageId: messageId,
            id: tagetId,
            title: "Placeholder",
            description: "Placeholder",
            sizeInBytes: nil,
            resolvedLayoutValue: .basic,
            objectIconImage: .object(.defaultObjectIcon),
            source: nil,
            syncStatus: nil,
            syncError: nil,
            downloadingState: true,
            style: style
        )
    }
}
