import Services

struct FullChatMessage: Equatable {
    let message: ChatMessage
    let attachments: [ObjectDetails]
    let reply: ChatMessage?
    let replyAttachments: [ObjectDetails]
}
