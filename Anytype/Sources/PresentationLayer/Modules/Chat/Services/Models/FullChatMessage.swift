import Services

struct FullChatMessage: Equatable, Identifiable {
    let message: ChatMessage
    let attachments: [ObjectDetails]
    let reply: ChatMessage?
    let replyAttachments: [ObjectDetails]
    
    var id: String { message.id }
}
