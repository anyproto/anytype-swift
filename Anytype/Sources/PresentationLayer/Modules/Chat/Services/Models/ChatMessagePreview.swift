struct ChatMessagePreview: Hashable {
    let spaceId: String
    let chatId: String
    var unreadCounter: Int
    var mentionCounter: Int
    
    var lastMessage: String
}

extension ChatMessagePreview {
    init(spaceId: String, chatId: String) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.unreadCounter = 0
        self.mentionCounter = 0
        
        self.lastMessage = ""
    }
}
