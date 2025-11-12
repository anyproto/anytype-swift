import Foundation

struct MessagePreviewModel: Equatable {
    let creatorTitle: String?
    let text: String
    let attachments: [Attachment]
    let localizedAttachmentsText: String
    let chatPreviewDate: String
    let unreadCounter: Int
    let mentionCounter: Int
    let isMuted: Bool
}

extension MessagePreviewModel {
    struct Attachment: Equatable, Identifiable {
        let id: String
        let icon: Icon
    }
}
