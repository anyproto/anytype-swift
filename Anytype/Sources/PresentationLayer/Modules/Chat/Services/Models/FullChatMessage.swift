import Services

struct FullChatMessage: Equatable {
    let message: ChatMessage
    let attachments: [MessageAttachmentDetails]
    let reply: ChatMessage?
    let replyAttachments: [MessageAttachmentDetails]
}
