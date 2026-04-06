import SwiftUI
import Services

protocol DiscussionMessageBuilderProtocol: AnyObject, Sendable {
    func makeMessage(
        messages: [FullChatMessage],
        participants: [Participant],
        limits: any ChatMessageLimitsProtocol
    ) async -> [MessageSectionData]
}

actor DiscussionMessageBuilder: DiscussionMessageBuilderProtocol, Sendable {

    private let accountParticipantsStorage: any ParticipantsStorageProtocol = Container.shared.participantsStorage()
    private let discussionTextBuilder: any DiscussionTextBuilderProtocol = Container.shared.discussionTextBuilder()
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()

    private let spaceId: String
    private let chatId: String

    private let timestampFormatter = MessageTimestampFormatter()

    init(spaceId: String, chatId: String) {
        self.spaceId = spaceId
        self.chatId = chatId
    }

    func makeMessage(
        messages: [FullChatMessage],
        participants: [Participant],
        limits: any ChatMessageLimitsProtocol
    ) async -> [MessageSectionData] {

        // Discussion always shows all authors equally, no left/right distinction
        let participant = accountParticipantsStorage.participants.first { $0.spaceId == spaceId }
        let chatObject = openDocumentProvider.document(objectId: chatId, spaceId: spaceId)
        let isChatDeletedOrArchived = (chatObject.details?.isDeleted ?? false) || (chatObject.details?.isArchived ?? false)
        let canEdit = (participant?.canEdit ?? false) && !isChatDeletedOrArchived
        let yourProfileIdentity = participant?.identity

        var items: [MessageSectionItem] = []

        for messageIndex in 0..<messages.count {

            let fullMessage = messages[messageIndex]
            let message = fullMessage.message

            let isYourMessage = message.creator == yourProfileIdentity
            let authorParticipant = participants.first { $0.identity == message.creator }
            let position: MessageHorizontalPosition = .left

            let messageModel = MessageViewData(
                spaceId: spaceId,
                chatId: chatId,
                authorName: authorParticipant?.title ?? "",
                authorIcon: authorParticipant?.icon.map { .object($0) } ?? Icon.object(.profile(.placeholder)),
                authorId: authorParticipant?.id,
                timestampLabel: makeTimestampLabel(message: message),
                messageString: AttributedString(),
                discussionBlocks: message.resolvedDiscussionBlocks(
                    spaceId: spaceId,
                    position: position,
                    textBuilder: discussionTextBuilder,
                    attachmentDetails: Dictionary(fullMessage.attachments.map { ($0.id, $0) }, uniquingKeysWith: { _, last in last })
                ),
                replyModel: mapReply(
                    fullMessage: fullMessage,
                    participants: participants,
                    yourProfileIdentity: yourProfileIdentity
                )
                ,
                position: position,
                linkedObjects: mapAttachments(fullMessage: fullMessage),
                reactions: mapReactions(
                    fullMessage: fullMessage,
                    participants: participants,
                    yourProfileIdentity: yourProfileIdentity,
                    position: position
                ),
                canAddReaction: canEdit && limits.canAddReaction(message: fullMessage.message, yourProfileIdentity: yourProfileIdentity ?? ""),
                canToggleReaction: canEdit,
                canReply: canEdit,
                nextSpacing: .disable,
                authorIconMode: .show,
                showAuthorName: true,
                canDelete: isYourMessage && canEdit,
                canEdit: isYourMessage && canEdit,
                showMessageSyncIndicator: isYourMessage,
                isMember: authorParticipant?.globalName.isNotEmpty ?? false,
                showTopDivider: messageIndex > 0,
                message: message,
                attachmentsDetails: fullMessage.attachments,
                reply: fullMessage.reply
            )

            items.append(.message(messageModel))
        }

        guard items.isNotEmpty else { return [] }

        // Discussions don't use section headers (date pill) — each comment shows its own timestamp.
        // Single section with empty header and static id since there's no day-based grouping.
        return [MessageSectionData(header: "", id: 0, items: items)]
    }

    private func makeTimestampLabel(message: ChatMessage) -> String {
        let timestamp = timestampFormatter.string(for: message.createdAtDate)
        if message.modifiedAtDate != nil {
            return "\(timestamp) (\(Loc.Message.edited))"
        }
        return timestamp
    }

    private func mapReactions(
        fullMessage: FullChatMessage,
        participants: [Participant],
        yourProfileIdentity: String?,
        position: MessageHorizontalPosition
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
                position: position
            )
        }.sorted { $0.content.sortWeight > $1.content.sortWeight }.sorted { $0.emoji < $1.emoji }
    }

    private func mapReply(fullMessage: FullChatMessage, participants: [Participant], yourProfileIdentity: String?) -> MessageReplyModel? {
        if let replyChat = fullMessage.reply {
            let replyAuthor = participants.first { $0.identity == fullMessage.reply?.creator }
            let replyAttachment = fullMessage.replyAttachments.first

            let imagesCount = fullMessage.replyAttachments.count(where: \.resolvedLayoutValue.isImage)
            let filesCout = fullMessage.replyAttachments.count(where: \.resolvedLayoutValue.isFile)

            let description: String
            let replyBlocks = replyChat.resolvedDiscussionBlocks(spaceId: spaceId, position: .left, textBuilder: discussionTextBuilder)
            let replyPlainText = replyBlocks.plainText
            if replyPlainText.isNotEmpty {
                description = replyPlainText
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

            return MessageReplyModel(
                author: replyAuthor?.title ?? "",
                description: description,
                attachmentIcon: replyAttachment?.objectIconImage,
                isYour: replyAuthor?.identity == yourProfileIdentity
            )
        }
        return nil
    }

    private func mapAttachments(fullMessage: FullChatMessage) -> MessageLinkedObjectsLayout? {
        let chatMessage = fullMessage.message

        guard chatMessage.attachments.isNotEmpty else {
            return nil
        }

        if fullMessage.attachments.count == 1,
           let attachment = fullMessage.attachments.first,
           attachment.resolvedLayoutValue.isBookmark {
            return .bookmark(attachment)
        }

        let linkedObjectsDetails = fullMessage.message.attachments.map { attachment in
            if let details = fullMessage.attachments.first(where: { $0.id == attachment.target }) {
                return MessageAttachmentDetails(details: details)
            } else {
                return MessageAttachmentDetails.placeholder(tagetId: attachment.target)
            }
        }

        let containsNotOnlyMediaFiles = linkedObjectsDetails.contains { $0.resolvedLayoutValue != .image && $0.resolvedLayoutValue != .video }

        if containsNotOnlyMediaFiles {
            return .list(linkedObjectsDetails)
        } else {
            return .grid(linkedObjectsDetails)
        }
    }
}
