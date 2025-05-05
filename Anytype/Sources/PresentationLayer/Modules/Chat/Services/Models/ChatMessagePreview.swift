import Services


struct ChatMessagePreview: Hashable {
    let spaceId: String
    let chatId: String
    
    var unreadCounter: Int
    var mentionCounter: Int
    
    var lastMessage: String
    var attachments: [ChatMessageAttachment]
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

extension Array where Element == ChatMessageAttachment {
    var localizedCount: String {
        // TBD: real implementation
        switch count {
        case 0:
            ""
        case 1:
            "Attachement"
        default:
            "\(count) Attachements"
        }
    }
}
