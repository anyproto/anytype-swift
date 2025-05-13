import Services
import Foundation

struct LastMessagePreview: Hashable {
    let creator: ObjectDetails?
    let text: String
    
    let createdAt: Date
    let modifiedAt: Date?
    
    let attachments: [ObjectDetails]
    let localizedAttachmentsText: String
    
    init(creator: ObjectDetails?, text: String, createdAt: Date, modifiedAt: Date?, attachments: [ObjectDetails]) {
        self.creator = creator
        self.text = text
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.attachments = attachments
        self.localizedAttachmentsText = AttachmentsTextInfoBuilder
            .localizedAttachmentsText(attachments: attachments)
    }
}

struct ChatMessagePreview: Hashable {
    let spaceId: String
    let chatId: String
    
    var unreadCounter: Int
    var mentionCounter: Int
    
    var lastMessage: LastMessagePreview?
}

extension ChatMessagePreview {
    init(spaceId: String, chatId: String) {
        self.spaceId = spaceId
        self.chatId = chatId
        
        self.unreadCounter = 0
        self.mentionCounter = 0
        
        self.lastMessage = nil
    }
}
