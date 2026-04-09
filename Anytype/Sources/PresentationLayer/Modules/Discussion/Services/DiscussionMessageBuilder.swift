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
    private let embedContentDataBuilder: any EmbedContentDataBuilderProtocol = Container.shared.embedContentDataBuilder()
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()

    private let spaceId: String
    private let chatId: String

    private let timestampFormatter = MessageTimestampFormatter()
    private let threadGrouper = DiscussionThreadGrouper()

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
        let participantByIdentity = Dictionary(
            participants.map { ($0.identity, $0) },
            uniquingKeysWith: { _, last in last }
        )

        // Thread grouping: reorder messages so replies appear directly after their root parent
        let result = threadGrouper.groupMessagesIntoThreads(messages: messages)
        let roots = result.roots
        let threadReplies = result.threadReplies

        var items: [MessageSectionItem] = []
        var isFirstRoot = true

        for root in roots {
            if !isFirstRoot {
                items.append(.discussionDivider(id: "divider-\(root.message.id)", orderID: root.message.orderID))
            }

            let rootModel = buildMessageViewData(
                fullMessage: root,
                participantByIdentity: participantByIdentity,
                yourProfileIdentity: yourProfileIdentity,
                canEdit: canEdit,
                limits: limits,
                isReply: false,
                isLastReply: false
            )
            items.append(.message(rootModel))
            isFirstRoot = false

            // Emit sorted replies directly after the root
            if let replies = threadReplies[root.message.id] {
                for (index, reply) in replies.enumerated() {
                    let replyModel = buildMessageViewData(
                        fullMessage: reply,
                        participantByIdentity: participantByIdentity,
                        yourProfileIdentity: yourProfileIdentity,
                        canEdit: canEdit,
                        limits: limits,
                        isReply: true,
                        isLastReply: index == replies.count - 1
                    )
                    items.append(.message(replyModel))
                }
            }
        }

        guard items.isNotEmpty else { return [] }

        // Discussions don't use section headers (date pill) — each comment shows its own timestamp.
        // Single section with empty header and static id since there's no day-based grouping.
        return [MessageSectionData(header: "", id: 0, items: items)]
    }

    // MARK: - Message Building

    private func buildMessageViewData(
        fullMessage: FullChatMessage,
        participantByIdentity: [String: Participant],
        yourProfileIdentity: String?,
        canEdit: Bool,
        limits: any ChatMessageLimitsProtocol,
        isReply: Bool,
        isLastReply: Bool
    ) -> MessageViewData {
        let message = fullMessage.message
        let isYourMessage = message.creator == yourProfileIdentity
        let authorParticipant = participantByIdentity[message.creator]
        let position: MessageHorizontalPosition = .left

        return MessageViewData(
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
                embedContentDataBuilder: embedContentDataBuilder,
                attachmentDetails: Dictionary(fullMessage.attachments.map { ($0.id, $0) }, uniquingKeysWith: { _, last in last })
            ),
            replyModel: nil,
            position: position,
            linkedObjects: mapAttachments(fullMessage: fullMessage),
            reactions: mapReactions(
                fullMessage: fullMessage,
                participantByIdentity: participantByIdentity,
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
            isReply: isReply,
            isLastReply: isLastReply,
            message: message,
            attachmentsDetails: fullMessage.attachments,
            reply: nil
        )
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
        participantByIdentity: [String: Participant],
        yourProfileIdentity: String?,
        position: MessageHorizontalPosition
    ) -> [MessageReactionModel] {
        fullMessage.message.reactions.reactions.map { (key, value) -> MessageReactionModel in

            let content: MessageReactionModelContent

            if value.ids.count == 1, let firstId = value.ids.first {
                let icon = participantByIdentity[firstId]?.icon.map({ Icon.object($0) })
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
