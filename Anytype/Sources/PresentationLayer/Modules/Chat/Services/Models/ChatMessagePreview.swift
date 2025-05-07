import Services
import Foundation

struct LastMessagePreview: Hashable {
    var creator: Participant?
    var text: String
    
    var createdAt: Date?
    var modifiedAt: Date?
    
    var attachments: [ObjectDetails]
    
    var messagePreviewText: String { text.isNotEmpty ? text : localizedAttachmentsText }
    
    var localizedAttachmentsText: String {
        // TBD: real implementation
        switch attachments.count {
        case 0:
            ""
        case 1:
            "Attachement"
        default:
            "\(attachments.count) Attachements"
        }
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
