struct ChatMessagePreview: Hashable {
    let spaceId: String
    let chatId: String
    let unreadCounter: Int
    let mentionCounter: Int
    
    let lastMessage: String
    
    func updated(unreadCounter: Int, mentionCounter: Int) -> ChatMessagePreview {
        ChatMessagePreview(
            spaceId: spaceId,
            chatId: chatId,
            unreadCounter: unreadCounter,
            mentionCounter: mentionCounter,
            lastMessage: lastMessage
        )
    }
    
    func updated(lastMessage: String) -> ChatMessagePreview {
        ChatMessagePreview(
            spaceId: spaceId,
            chatId: chatId,
            unreadCounter: unreadCounter,
            mentionCounter: mentionCounter,
            lastMessage: lastMessage
        )
    }
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
