import Services


struct ChatMessagePreview: Hashable {
    let spaceId: String
    let chatId: String
    
    var unreadCounter: Int
    var mentionCounter: Int
    
    var lastMessage: String
    var attachments: [ObjectDetails]
}

extension ChatMessagePreview {
    init(spaceId: String, chatId: String) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.unreadCounter = 0
        self.mentionCounter = 0
        
        self.lastMessage = ""
        self.attachments = []
    }
}

extension ChatMessagePreview {
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
