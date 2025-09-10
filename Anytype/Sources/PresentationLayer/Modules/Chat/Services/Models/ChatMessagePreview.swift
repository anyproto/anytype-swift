import Services
import Foundation

struct LastMessagePreview: Hashable {
    let creator: Participant?
    let text: String
    
    let createdAt: Date
    let modifiedAt: Date?
    
    let attachments: [ObjectDetails]
    let localizedAttachmentsText: String
    
    init(creator: Participant?, text: String, createdAt: Date, modifiedAt: Date?, attachments: [ObjectDetails]) {
        self.creator = creator
        self.text = text
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.attachments = attachments
        self.localizedAttachmentsText = text.isNotEmpty ? text : AttachmentsTextInfoBuilder
            .localizedAttachmentsText(attachments: attachments)
    }
}

struct ChatMessagePreview: Hashable {
    let spaceId: String
    let chatId: String
    
    var state: ChatState?
    var lastMessage: LastMessagePreview?
    
    var unreadCounter: Int {
        Int(state?.messages.counter ?? 0)
    }
    
    var mentionCounter: Int {
        Int(state?.mentions.counter ?? 0)
    }
    
    var hasCounters: Bool {
        unreadCounter > 0 || mentionCounter > 0
    }
}

extension ChatMessagePreview {
    init(spaceId: String, chatId: String) {
        self.spaceId = spaceId
        self.chatId = chatId
        
        self.state = nil
        self.lastMessage = nil
    }
}
