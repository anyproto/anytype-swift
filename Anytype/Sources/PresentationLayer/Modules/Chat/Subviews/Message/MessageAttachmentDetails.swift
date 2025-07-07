import SwiftUI
import Services

struct MessageAttachmentDetails: Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let sizeInBytes: Int?
    let resolvedLayoutValue: DetailsLayout
    let objectIconImage: Icon
    let source: String?
    let downloadingState: Bool
}

extension MessageAttachmentDetails {
    init(details: ObjectDetails) {
        let source = details.source?.url.host() ?? details.source?.absoluteString
        self = MessageAttachmentDetails(
            id: details.id,
            title: details.title,
            description: details.objectType.displayName,
            sizeInBytes: details.sizeInBytes,
            resolvedLayoutValue: details.resolvedLayoutValue,
            objectIconImage: details.objectIconImage,
            source: source,
            downloadingState: false
        )
    }
    
    static func placeholder(tagetId: String) -> Self {
        MessageAttachmentDetails(
            id: tagetId,
            title: "Placeholder",
            description: "Placeholder",
            sizeInBytes: nil,
            resolvedLayoutValue: .basic,
            objectIconImage: .object(.defaultObjectIcon),
            source: nil,
            downloadingState: true
        )
    }
}
