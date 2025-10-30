import Foundation

struct SpaceCardLastMessageModel: Equatable {
    let creatorTitle: String?
    let text: String
    let attachments: [Attachment]
    let localizedAttachmentsText: String
    let historyDate: String
    let chatPreviewDate: String
}

extension SpaceCardLastMessageModel {
    struct Attachment: Equatable, Identifiable {
        let id: String
        let icon: Icon
    }
}
