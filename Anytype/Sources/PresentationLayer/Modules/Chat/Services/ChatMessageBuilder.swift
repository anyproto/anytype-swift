import SwiftUI
import Services

protocol ChatMessageBuilderProtocol: AnyObject {
    func makeMessage(messages: [ChatMessage], participants: [Participant]) async -> [MessageSectionData]
}

final class ChatMessageBuilder: ChatMessageBuilderProtocol {
    
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    
    let spaceId: String
    let chatId: String
    let chatStorage: any ChatMessagesStorageProtocol
    
    init(spaceId: String, chatId: String, chatStorage: any ChatMessagesStorageProtocol) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.chatStorage = chatStorage
    }
    
    func makeMessage(messages: [ChatMessage], participants: [Participant]) async -> [MessageSectionData] {
        
        let yourProfileIdentity = await accountParticipantsStorage.participants.first?.identity
        
        let newMessages = await messages.asyncMap { message -> MessageViewData in
            
            let reactions = message.reactions.reactions.map { (key, value) -> MessageReactionModel in
                
                let content: MessageReactionModelContent
                
                if value.ids.count == 1,
                   let firstId = value.ids.first,
                   let icon = participants.first(where: { $0.identity == firstId })?.icon.map({ Icon.object($0) }) {
                       content = .icon(icon)
                   } else {
                       content = .count(value.ids.count)
                   }
                
                return MessageReactionModel(
                    emoji: key,
                    content: content,
                    selected: yourProfileIdentity.map { value.ids.contains($0) } ?? false
                )
            }.sorted { $0.content.sortWeight > $1.content.sortWeight }.sorted { $0.emoji < $1.emoji }
            
            let replyMessage = await chatStorage.reply(message: message)
            let replyAttachments = await replyMessage.asyncMap { await chatStorage.attachments(message: $0) } ?? []
            
            return MessageViewData(
                spaceId: spaceId,
                chatId: chatId,
                message: message,
                participant: participants.first { $0.identity == message.creator },
                reactions: reactions,
                attachmentsDetails: await chatStorage.attachments(message: message),
                reply: replyMessage,
                replyAttachments: replyAttachments,
                replyAuthor: participants.first { $0.identity == replyMessage?.creator }
            )
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        var currentSectionData: MessageSectionData?
        var newMessageBlocks: [MessageSectionData] = []
        
        let calendar = Calendar.current
        
        for newMessage in newMessages {
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: newMessage.message.createdAtDate)
            let date = calendar.date(from: dateComponents) ?? newMessage.message.createdAtDate
            
            if currentSectionData?.id == date.hashValue {
                currentSectionData?.items.append(newMessage)
            } else {
                if let currentSectionData {
                    newMessageBlocks.append(currentSectionData)
                }
                currentSectionData = MessageSectionData(header: dateFormatter.string(from: date), id: date.hashValue, items: [newMessage])
            }
        }
        
        if let currentSectionData {
            newMessageBlocks.append(currentSectionData)
        }
        
        return newMessageBlocks
    }
}
