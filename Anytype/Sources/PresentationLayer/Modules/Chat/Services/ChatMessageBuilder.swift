import SwiftUI
import Services

protocol ChatMessageBuilderProtocol: AnyObject, Sendable {
    func makeMessage(
        messages: [FullChatMessage],
        participants: [Participant],
        firstUnreadMessageOrderId: String?,
        limits: any ChatMessageLimitsProtocol
    ) async -> [MessageSectionData]
}

actor ChatMessageBuilder: ChatMessageBuilderProtocol, Sendable {
    
    private enum Constants {
        static let grouppingDateInterval: Int = 60 // seconds
    }
    
    private let accountParticipantsStorage: any AccountParticipantsStorageProtocol = Container.shared.accountParticipantsStorage()
    private let messageTextBuilder: any MessageTextBuilderProtocol = Container.shared.messageTextBuilder()
    private let workspaceStorage: any WorkspacesStorageProtocol = Container.shared.workspaceStorage()
    
    private let spaceId: String
    private let chatId: String
    
    private let dateFormatter = HistoryDateFormatter()
    
    init(spaceId: String, chatId: String) {
        self.spaceId = spaceId
        self.chatId = chatId
    }
    
    func makeMessage(
        messages: [FullChatMessage],
        participants: [Participant],
        firstUnreadMessageOrderId: String?,
        limits: any ChatMessageLimitsProtocol
    ) async -> [MessageSectionData] {
        let backgroundColor: UIColor = .black.withAlphaComponent(0.5)
        
        let isStream = workspaceStorage.spaceView(spaceId: spaceId)?.uxType.isStream ?? false
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
            let lastInSectionDate = firstInSection ? createDateDay : (sectionDateDay ?? createDateDay)
            let lastInSection = nextMessage.map { dayDate(for: $0.createdAtDate).timeIntervalSince1970 > lastInSectionDate.timeIntervalSince1970 } ?? true
            let firstForCurrentUser = prevCreator != message.creator
            let prevDateIntervalIsBig = prevDateInterval.map { (message.createdAt - $0) > Constants.grouppingDateInterval } ?? true
            let nextDateIntervalIsBig = nextMessage.map { ($0.createdAt - message.createdAt) > Constants.grouppingDateInterval } ?? true
            
            let lastForCurrentUser = nextMessage?.creator != message.creator
            
            let isYourMessage = message.creator == yourProfileIdentity
            let authorParticipant = participants.first { $0.identity == message.creator }
            let position: MessageHorizontalPosition = (isYourMessage && !isStream) ? .right : .left
            let isUnread = message.orderID == firstUnreadMessageOrderId
            let nextIsUnread = nextMessage?.orderID == firstUnreadMessageOrderId
            
//            let messageModel = MessageViewData(
//                spaceId: spaceId,
//                chatId: chatId,
//                authorName: authorParticipant?.title ?? "",
//                authorIcon: authorParticipant?.icon.map { .object($0) } ?? Icon.object(.profile(.placeholder)),
//                authorId: authorParticipant?.id,
//                createDate: message.createdAtDate.formatted(date: .omitted, time: .shortened),
//                messageString: messageTextBuilder.makeMessage(content: message.message, spaceId: spaceId, position: position),
//                replyModel: mapReply(
//                    fullMessage: fullMessage,
//                    participants: participants,
//                    yourProfileIdentity: yourProfileIdentity
//                )
//                ,
//                position: position,
//                linkedObjects: mapAttachments(fullMessage: fullMessage),
//                reactions: mapReactions(
//                    fullMessage: fullMessage,
//                    participants: participants,
//                    yourProfileIdentity: yourProfileIdentity,
//                    position: position
//                ),
//                canAddReaction: canEdit && limits.canAddReaction(message: fullMessage.message, yourProfileIdentity: yourProfileIdentity ?? ""),
//                canReply: canEdit,
//                nextSpacing: (lastInSection || nextIsUnread) ? .disable : (lastForCurrentUser || nextDateIntervalIsBig ? .medium : .small),
//                authorIconMode: (isYourMessage || isStream) ? .hidden : (lastForCurrentUser || lastInSection || nextDateIntervalIsBig ? .show : .empty),
//                showAuthorName: (firstForCurrentUser || prevDateIntervalIsBig) && !isYourMessage && !isStream,
//                canDelete: isYourMessage && canEdit,
//                canEdit: isYourMessage && canEdit,
//                showMessageSyncIndicator: isYourMessage,
//                message: message,
//                attachmentsDetails: fullMessage.attachments,
//                reply: fullMessage.reply
//            )
            let canAddReaction = canEdit && limits.canAddReaction(message: fullMessage.message, yourProfileIdentity: yourProfileIdentity ?? "")
            let messageModel = MesageUIViewData(
                id: fullMessage.message.id,
                orderId: fullMessage.message.orderID,
                authorIcon: authorParticipant?.icon.map { .object($0) } ?? Icon.object(.profile(.placeholder)),
                authorIconMode: (isYourMessage || isStream) ? .hidden : (lastForCurrentUser || lastInSection || nextDateIntervalIsBig ? .show : .empty),
                bubble: MessageBubbleViewData(
                    messageId: fullMessage.message.id,
                    messageText: messageTextBuilder.makeMessage(content: message.message, spaceId: spaceId, position: position),
                    linkedObjects: mapAttachments(fullMessage: fullMessage, position: position),
                    position: position,
                    messageYourBackgroundColor: backgroundColor,
                    canAddReaction: canAddReaction,
                    canReply: canEdit,
                    canEdit: isYourMessage && canEdit,
                    canDelete: isYourMessage && canEdit
                ),
                reply: mapReply(
                    fullMessage: fullMessage,
                    participants: participants,
                    yourProfileIdentity: yourProfileIdentity,
                    messageYourBackgroundColor: backgroundColor
                ),
                reactions: mapReactions(
                    fullMessage: fullMessage,
                    participants: participants,
                    yourProfileIdentity: yourProfileIdentity,
                    position: position,
                    messageYourBackgroundColor: backgroundColor,
                    canAddReaction: canAddReaction,
                ),
                nextSpacing: (lastInSection || nextIsUnread) ? .disable : (lastForCurrentUser || nextDateIntervalIsBig ? .medium : .small),
                position: position
            )
            
            let unreadItem: MessageSectionItem? = isUnread ? .unread("\(message.id)-unread") : nil
            
            if firstInSection {
                if let currentSectionData {
                    newMessageBlocks.append(currentSectionData)
                }
                currentSectionData = MessageSectionData(
                    header: dateFormatter.localizedDateString(for: createDateDay),
                    id: createDateDay.hashValue,
                    items: []
                )
                sectionDateDay = createDateDay
            }
            
            if let unreadItem {
                currentSectionData?.items.append(unreadItem)
            }
            currentSectionData?.items.append(.message(messageModel))
            
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
        position: MessageHorizontalPosition,
        messageYourBackgroundColor: UIColor,
        canAddReaction: Bool
    ) -> MessageReactionListData? {
        if fullMessage.message.reactions.reactions.isEmpty {
            return nil
        }
        
        let reactions = fullMessage.message.reactions.reactions.map { (key, value) -> MessageReactionData in
            
            let content: MessageReactionModelContent
            
            if value.ids.count == 1, let firstId = value.ids.first {
                let icon = participants.first(where: { $0.identity == firstId })?.icon.map({ Icon.object($0) })
                content = .icon(icon ?? Icon.object(.profile(.placeholder)))
            } else {
                content = .count(value.ids.count)
            }
            
            return MessageReactionData(
                emoji: key,
                content: content,
                selected: yourProfileIdentity.map { value.ids.contains($0) } ?? false,
                position: position,
                messageYourBackgroundColor: messageYourBackgroundColor
            )
        }.sorted { $0.content.sortWeight > $1.content.sortWeight }.sorted { $0.emoji < $1.emoji }
        
        return MessageReactionListData(
            reactions: reactions,
            canAddReaction: canAddReaction,
            position: position
        )
    }
    
    private func mapReply(fullMessage: FullChatMessage, participants: [Participant], yourProfileIdentity: String?, messageYourBackgroundColor: UIColor) -> MessageReplyViewData? {
        if let replyChat = fullMessage.reply {
            let replyAuthor = participants.first { $0.identity == fullMessage.reply?.creator }
            let replyAttachment = fullMessage.replyAttachments.first
            
            let imagesCount = fullMessage.replyAttachments.count(where: \.resolvedLayoutValue.isImage)
            let filesCout = fullMessage.replyAttachments.count(where: \.resolvedLayoutValue.isFile)
            
            let description: String
            if replyChat.message.text.isNotEmpty {
                // Without style. Request from designers.
                description = messageTextBuilder
                    .makeMessaeWithoutStyle(content: replyChat.message)
                    .replacingOccurrences(of: "\n+", with: "\n", options: .regularExpression)
            } else if fullMessage.replyAttachments.count == 1 {
                description = replyAttachment?.title ?? ""
            } else if imagesCount == fullMessage.replyAttachments.count {
                description = Loc.Chat.Reply.images(fullMessage.replyAttachments.count)
            } else if filesCout == fullMessage.replyAttachments.count {
                description = Loc.Chat.Reply.files(fullMessage.replyAttachments.count)
            } else {
                description = Loc.Chat.Reply.attachments(fullMessage.replyAttachments.count)
            }
            
            return MessageReplyViewData(
                messageId: fullMessage.message.id,
                author: replyAuthor?.title ?? "",
                description: description,
                attachmentIcon: replyAttachment?.objectIconImage,
                isYour: replyAuthor?.identity == yourProfileIdentity,
                messageYourBackgroundColor: messageYourBackgroundColor
            )
        }
        return nil
    }
    
    private func mapAttachments(fullMessage: FullChatMessage, position: MessageHorizontalPosition) -> MessageBubbleAttachments? {
        let chatMessage = fullMessage.message
        
        guard chatMessage.attachments.isNotEmpty else {
            return nil
        }
        
        if fullMessage.attachments.count == 1,
            let attachment = fullMessage.attachments.first,
            attachment.resolvedLayoutValue.isBookmark {
            let bookmark = MessageBigBookmarkViewData(
                messageId: fullMessage.message.id,
                details: attachment,
                position: position
            )
            return .bookmark(bookmark)
        }
        
        let style: MessageAttachmentStyle = position.isRight ? .messageYour : .messageOther
        
        var attachmentsDetails = fullMessage.attachments.map { MessageAttachmentDetails(messageId: fullMessage.message.id, details: $0, style: style) }
        
        // Add empty objects
        for attachment in fullMessage.message.attachments {
            if !attachmentsDetails.contains(where: { $0.id == attachment.target }) {
                attachmentsDetails.append(MessageAttachmentDetails.placeholder(messageId: fullMessage.message.id, tagetId: attachment.target, style: style))
            }
        }
        
        let linkedObjectsDetails = attachmentsDetails.sorted { $0.id > $1.id }
        
        let containsNotOnlyMediaFiles = linkedObjectsDetails.contains { $0.resolvedLayoutValue != .image && $0.resolvedLayoutValue != .video }
        
        if containsNotOnlyMediaFiles {
            return .list(MessageListAttachmentsViewData(messageId: fullMessage.message.id, objects: linkedObjectsDetails, position: position))
        } else {
            return .grid(linkedObjectsDetails)
        }
    }
}
