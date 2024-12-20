import SwiftUI
import Services

protocol ChatMessageBuilderProtocol: AnyObject {
    func makeMessage(messages: [FullChatMessage], participants: [Participant], limits: any ChatMessageLimitsProtocol) async -> [MessageSectionData]
}

final class ChatMessageBuilder: ChatMessageBuilderProtocol {
    
    private enum Constants {
        static let grouppingDateInterval: Int = 5 * 60 // seconds
    }
    
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    @Injected(\.messageAttachmentsGridLayoutBuilder)
    private var gridLayoutBuilder: any MessageAttachmentsGridLayoutBuilderProtocol
    @Injected(\.messageTextBuilder)
    private var messageTextBuilder: any MessageTextBuilderProtocol
    
    private let spaceId: String
    private let chatId: String
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
    
    init(spaceId: String, chatId: String) {
        self.spaceId = spaceId
        self.chatId = chatId
    }
    
    func makeMessage(messages: [FullChatMessage], participants: [Participant], limits: any ChatMessageLimitsProtocol) async -> [MessageSectionData] {
        
        let participant = accountParticipantsStorage.participants.first { $0.spaceId == spaceId }
        let canEdit = participant?.canEdit ?? false
        let yourProfileIdentity = participant?.identity
        
        var currentSectionData: MessageSectionData?
        var newMessageBlocks: [MessageSectionData] = []
        
        var prevDateInterval: Int64?
        var prevCreator: String?
        var sectionDateDay: Date?
        
        for messageIndex in 0..<messages.count {
            
            let fullMessage = messages[messageIndex]
            let message = fullMessage.message
            let nextMessage = messages[safe: messageIndex + 1]?.message
            
            let createDateDay = dayDate(for: message.createdAtDate)
            
            let firstInSection = sectionDateDay.map { $0.timeIntervalSince1970 < createDateDay.timeIntervalSince1970 } ?? true
            let lastInSection = nextMessage.map { dayDate(for: $0.createdAtDate).timeIntervalSince1970 > createDateDay.timeIntervalSince1970 } ?? true
            let firstForCurrentUser = prevCreator != message.creator
            let prevDateIntervalIsBig = prevDateInterval.map { (message.createdAt - $0) > Constants.grouppingDateInterval } ?? true
            let nextDateIntervalIsBig = nextMessage.map { ($0.createdAt - message.createdAt) > Constants.grouppingDateInterval } ?? true
            
            let lastForCurrentUser = nextMessage?.creator != message.creator
            
            let isYourMessage = message.creator == yourProfileIdentity
            
            let authorParticipant = participants.first { $0.identity == message.creator }
            
            let messageModel = MessageViewData(
                spaceId: spaceId,
                chatId: chatId,
                authorName: authorParticipant?.title ?? "",
                authorIcon: authorParticipant?.icon.map { .object($0) } ?? Icon.object(.profile(.placeholder)),
                createDate: message.createdAtDate.formatted(date: .omitted, time: .shortened),
                messageString: messageTextBuilder.makeMessage(content: message.message, isYourMessage: isYourMessage),
                replyModel: mapReply(
                    fullMessage: fullMessage,
                    participants: participants,
                    isYourMessage: isYourMessage)
                ,
                isYourMessage: isYourMessage,
                linkedObjects: mapAttachments(fullMessage: fullMessage),
                reactions: mapReactions(
                    fullMessage: fullMessage,
                    participants: participants,
                    yourProfileIdentity: yourProfileIdentity,
                    isYourMessage: isYourMessage
                ),
                canAddReaction: limits.canAddReaction(message: fullMessage.message, yourProfileIdentity: yourProfileIdentity ?? ""),
                nextSpacing: lastInSection ? .disable : (lastForCurrentUser || nextDateIntervalIsBig ? .medium : .small),
                authorMode: isYourMessage ? .hidden : (lastForCurrentUser || lastInSection || nextDateIntervalIsBig ? .show : .empty),
                showHeader: firstForCurrentUser || prevDateIntervalIsBig,
                canDelete: isYourMessage && canEdit,
                canEdit: isYourMessage && canEdit,
                message: message,
                attachmentsDetails: fullMessage.attachments,
                reply: fullMessage.reply
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
    
    private func mapReactions(
        fullMessage: FullChatMessage,
        participants: [Participant],
        yourProfileIdentity: String?,
        isYourMessage: Bool
    ) -> [MessageReactionModel] {
        fullMessage.message.reactions.reactions.map { (key, value) -> MessageReactionModel in
            
            let content: MessageReactionModelContent
            
            if value.ids.count == 1, let firstId = value.ids.first {
                let icon = participants.first(where: { $0.identity == firstId })?.icon.map({ Icon.object($0) })
                content = .icon(icon ?? Icon.object(.profile(.placeholder)))
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
    }
    
    private func mapReply(fullMessage: FullChatMessage, participants: [Participant], isYourMessage: Bool) -> MessageReplyModel? {
        if let replyChat = fullMessage.reply {
            let replyAuthor = participants.first { $0.identity == fullMessage.reply?.creator }
            let replyAttachment = fullMessage.replyAttachments.first
            
            let imagesCount = fullMessage.replyAttachments.count(where: \.layoutValue.isImage)
            let filesCout = fullMessage.replyAttachments.count(where: \.layoutValue.isFile)
            
            let description: String
            if replyChat.message.text.isNotEmpty {
                // Without style. Request from designers.
                description = messageTextBuilder.makeMessaeWithoutStyle(content: replyChat.message)
            } else if fullMessage.replyAttachments.count == 1 {
                description = replyAttachment?.title ?? ""
            } else if imagesCount == fullMessage.replyAttachments.count {
                description = Loc.Chat.Reply.images(fullMessage.replyAttachments.count)
            } else if filesCout == fullMessage.replyAttachments.count {
                description = Loc.Chat.Reply.files(fullMessage.replyAttachments.count)
            } else {
                description = Loc.Chat.Reply.attachments(fullMessage.replyAttachments.count)
            }
            
            return MessageReplyModel(
                author: replyAuthor?.title ?? "",
                description: description,
                icon: replyAttachment?.objectIconImage,
                isYour: isYourMessage
            )
        }
        return nil
    }
    
    private func mapAttachments(fullMessage: FullChatMessage) -> MessageLinkedObjectsLayout? {
        let chatMessage = fullMessage.message
        
        guard chatMessage.attachments.isNotEmpty else {
            return nil
        }
        
        var attachmentsDetails = fullMessage.attachments.map { MessageAttachmentDetails(details: $0) }
        
        // Add empty objects
        for attachment in fullMessage.message.attachments {
            if !attachmentsDetails.contains(where: { $0.id == attachment.target }) {
                attachmentsDetails.append(MessageAttachmentDetails(details: ObjectDetails(id: attachment.target)))
            }
        }
        
        let linkedObjectsDetails = attachmentsDetails.sorted { $0.id > $1.id }
        
        let containsNotOnlyMediaFiles = linkedObjectsDetails.contains { $0.layoutValue != .image && $0.layoutValue != .video }
        
        if containsNotOnlyMediaFiles {
            return .list(linkedObjectsDetails)
        } else {
            let gridItems = gridLayoutBuilder.makeGridRows(countItems: linkedObjectsDetails.count)
            var prevIndex = 0
            let items = gridItems.map { itemsCount in
                let nextIndex = prevIndex + itemsCount
                let items = linkedObjectsDetails[prevIndex..<nextIndex]
                prevIndex = nextIndex
                return Array(items)
            }
            return .grid(items)
        }
    }
}
