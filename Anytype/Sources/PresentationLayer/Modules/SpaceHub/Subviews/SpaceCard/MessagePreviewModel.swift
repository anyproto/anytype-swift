import Foundation

struct MessagePreviewModel: Equatable, Hashable {
    let creatorTitle: String?
    let text: String
    let attachments: [Attachment]
    let localizedAttachmentsText: String
    let chatPreviewDate: String
    let unreadCounter: Int
    let mentionCounter: Int
    let isMuted: Bool
    let chatName: String?
}

extension MessagePreviewModel {
    struct Attachment: Equatable, Hashable, Identifiable {
        let id: String
        let icon: Icon
    }
}
