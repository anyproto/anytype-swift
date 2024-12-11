import SwiftUI
import Services

protocol ChatMessageBuilderProtocol: AnyObject {
    func makeMessage(messages: [ChatMessage], participants: [Participant]) async -> [MessageSectionData]
}

final class ChatMessageBuilder: ChatMessageBuilderProtocol {
    
    private enum Constants {
        static let grouppingDateInterval: Int = 5 * 60 // seconds
    }
    
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    
    private let spaceId: String
    private let chatId: String
    private let chatStorage: any ChatMessagesStorageProtocol
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
    
    init(spaceId: String, chatId: String, chatStorage: any ChatMessagesStorageProtocol) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.chatStorage = chatStorage
    }
    
    func makeMessage(messages: [ChatMessage], participants: [Participant]) async -> [MessageSectionData] {
        
        let participant = accountParticipantsStorage.participants.first { $0.spaceId == spaceId }
        let canEdit = participant?.canEdit ?? false
        let yourProfileIdentity = participant?.identity
        
        var currentSectionData: MessageSectionData?
        var newMessageBlocks: [MessageSectionData] = []
        
        var prevDateInterval: Int64?
        var prevCreator: String?
        var sectionDateDay: Date?
        
        for messageIndex in 0..<messages.count {
            
            let message = messages[messageIndex]
            let nextMessage = messages[safe: messageIndex + 1]
            
            let createDateDay = dayDate(for: message.createdAtDate)
            
            let firstInSection = sectionDateDay.map { $0.timeIntervalSince1970 < createDateDay.timeIntervalSince1970 } ?? true
            let lastInSection = nextMessage.map { dayDate(for: $0.createdAtDate).timeIntervalSince1970 > createDateDay.timeIntervalSince1970 } ?? true
            let firstForCurrentUser = prevCreator != message.creator
            let prevDateIntervalIsBig = prevDateInterval.map { (message.createdAt - $0) > Constants.grouppingDateInterval } ?? true
            let nextDateIntervalIsBig = nextMessage.map { ($0.createdAt - message.createdAt) > Constants.grouppingDateInterval } ?? true
            
            let lastForCurrentUser = nextMessage?.creator != message.creator
            
            let isYourMessage = message.creator == yourProfileIdentity
            
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
                    selected: yourProfileIdentity.map { value.ids.contains($0) } ?? false,
                    isYourMessage: isYourMessage
                )
            }.sorted { $0.content.sortWeight > $1.content.sortWeight }.sorted { $0.emoji < $1.emoji }
            
            let replyMessage = await chatStorage.reply(message: message)
            let replyAttachments = await replyMessage.asyncMap { await chatStorage.attachments(message: $0) } ?? []
            
            let messageModel = MessageViewData(
                spaceId: spaceId,
                chatId: chatId,
                message: message,
                participant: participants.first { $0.identity == message.creator },
                reactions: reactions,
                attachmentsDetails: await chatStorage.attachments(message: message),
                reply: replyMessage,
                replyAttachments: replyAttachments,
                replyAuthor: participants.first { $0.identity == replyMessage?.creator },
                nextSpacing: lastInSection ? .disable : (lastForCurrentUser || nextDateIntervalIsBig ? .medium : .small),
                authorMode: isYourMessage ? .hidden : (lastForCurrentUser || firstInSection || nextDateIntervalIsBig ? .show : .empty),
                showHeader: firstForCurrentUser || prevDateIntervalIsBig,
                canDelete: isYourMessage && canEdit,
                canEdit: isYourMessage && canEdit
            )
            
            if firstInSection {
                if let currentSectionData {
                    newMessageBlocks.append(currentSectionData)
                }
                currentSectionData = MessageSectionData(
                    header: dateFormatter.string(from: createDateDay),
                    id: createDateDay.hashValue,
                    items: [messageModel]
                )
                sectionDateDay = createDateDay
            } else {
                currentSectionData?.items.append(messageModel)
            }
            
            
            prevCreator = message.creator
            prevDateInterval = message.createdAt
        }

        if let currentSectionData {
            newMessageBlocks.append(currentSectionData)
        }
        
        return newMessageBlocks
    }
    
    private func dayDate(for date: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: dateComponents) ?? date
    }
}
