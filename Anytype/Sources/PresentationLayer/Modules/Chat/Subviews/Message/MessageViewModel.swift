import Foundation
import Services
import SwiftUI
import AnytypeCore

struct MessageLinkObject {
    let details: ObjectDetails
    let type: ChatMessageAttachmentType
    
}
enum MessageLinkedObjectsLayout {
    case list([MessageAttachmentDetails])
    case grid([[MessageAttachmentDetails]])
}

@MainActor
final class MessageViewModel: ObservableObject {
    
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    private var data: MessageViewData
    private weak var output: (any MessageModuleOutput)?
    
    private let accountParticipantsStorage: any AccountParticipantsStorageProtocol = Container.shared.accountParticipantsStorage()
    private lazy var participantSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(data.spaceId)
    @Injected(\.objectIdsSubscriptionService)
    private var objectIdsSubscriptionService: any ObjectIdsSubscriptionServiceProtocol
    @Injected(\.messageAttachmentsGridLayoutBuilder)
    private var gridLayoutBuilder: any MessageAttachmentsGridLayoutBuilderProtocol
    
    @Published var message = AttributedString("")
    @Published var author: String = ""
    @Published var authorIcon: Icon?
    @Published var date: String = ""
    @Published var isYourMessage: Bool = false
    @Published var reactions: [MessageReactionModel] = []
    @Published var linkedObjects: MessageLinkedObjectsLayout?
    @Published var reply: MessageReplyModel?
    @Published var nextSpacing: MessageViewSpacing = .disable
    @Published var authorMode: MessageAuthorMode = .hidden
    @Published var showHeader: Bool = true
    @Published var canDelete: Bool = false
    @Published var canEdit: Bool = false
    
    private let yourProfileIdentity: String?
    private var linkedObjectsDetails: [MessageAttachmentDetails] = []
    
    init(data: MessageViewData, output: (any MessageModuleOutput)?) {
        self.data = data
        self.output = output
        self.yourProfileIdentity = accountParticipantsStorage.participants.first?.identity
        updateView()
    }
    
    func onTapAddReaction() {
        output?.didSelectAddReaction(messageId: data.message.id)
    }
    
    func onTapReaction(_ reaction: MessageReactionModel) async throws {
        try await chatService.toggleMessageReaction(chatObjectId: data.chatId, messageId: data.message.id, emoji: reaction.emoji)
    }
    
    func onLongTapReaction(_ reaction: MessageReactionModel) {
        let participantsIds = data.message.reactions.reactions[reaction.emoji]?.ids ?? []
        output?.didLongTapOnReaction(
            data: MessageParticipantsReactionData(
                spaceId: data.spaceId,
                emoji: reaction.emoji,
                participantsIds: participantsIds
            )
        )
    }
    
    private func updateView() {
        let chatMessage = data.message
        let authorParticipant = data.participant
        
        message = MessageTextBuilder.makeMessage(content: chatMessage.message)
        author = authorParticipant?.title ?? ""
        authorIcon = authorParticipant?.icon.map { .object($0) } ?? Icon.object(.profile(.placeholder))
        date = chatMessage.createdAtDate.formatted(date: .omitted, time: .shortened)
        isYourMessage = chatMessage.creator == yourProfileIdentity
        reactions = data.reactions
        nextSpacing = data.nextSpacing
        authorMode = data.authorMode
        showHeader = data.showHeader
        canDelete = data.canDelete
        canEdit = data.canEdit
        
        if let replyChat = data.reply {
            let replyAttachment = data.replyAttachments.first
            // Without style. Request from designers.
            let message = replyChat.message.text.isNotEmpty
                ? MessageTextBuilder.makeMessaeWithoutStyle(content: replyChat.message)
                : (replyAttachment?.title ?? "")
            reply = MessageReplyModel(
                author: data.replyAuthor?.title ?? "",
                description: message,
                icon: replyAttachment?.objectIconImage,
                isYour: isYourMessage
            )
        }
        
        var attachmentsDetails = data.attachmentsDetails
        
        // Add empty objects
        for attachment in data.message.attachments {
            if !attachmentsDetails.contains(where: { $0.id == attachment.target }) {
                attachmentsDetails.append(MessageAttachmentDetails(details: ObjectDetails(id: attachment.target)))
            }
        }
        
        linkedObjectsDetails = attachmentsDetails.sorted { $0.id > $1.id }
        updateAttachments()
    }
    
    func update(data: MessageViewData) {
        self.data = data
        withAnimation {
            updateView()
        }
        Task {
            await updateSubscription()
        }
    }
    
    func onAppear() {
        Task {
            await updateSubscription()
        }
    }
    
    func onDisappear() {
        Task {
            await objectIdsSubscriptionService.stopSubscription()
        }
    }
    
    func onTapObject(details: MessageAttachmentDetails) {
        output?.didSelectObject(details: details)
    }
    
    func onTapReplyTo() {
        output?.didSelectReplyTo(message: data)
    }
    
    func onTapReplyMessage() {
        output?.didSelectReplyMessage(message: data)
    }
    
    func onTapEdit() async {
        await output?.didSelectEditMessage(message: data)
    }
    
    func onTapDelete() {
        output?.didSelectDeleteMessage(message: data)
    }
    
    // MARK: - Private
    
    private func updateSubscription() async {
        let objectIds = data.message.attachments.map(\.target)
        if objectIds.isEmpty {
            await objectIdsSubscriptionService.stopSubscription()
        } else {
            await objectIdsSubscriptionService.startSubscription(spaceId: data.spaceId, objectIds: objectIds) { [weak self] linkedDetails in
                let linkedDetails = linkedDetails.map { MessageAttachmentDetails(details: $0) }.sorted { $0.id > $1.id }
                if self?.linkedObjectsDetails != linkedDetails {
                    self?.linkedObjectsDetails = linkedDetails
                    self?.updateAttachments()
                }
            }
        }
    }
    
    private func updateAttachments() {
        let chatMessage = data.message
        
        guard chatMessage.attachments.isNotEmpty else {
            linkedObjects = nil
            return
        }
        
        let containsNotOnlyMediaFiles = linkedObjectsDetails.contains { $0.layoutValue != .image && $0.layoutValue != .video }
        
        if containsNotOnlyMediaFiles {
            linkedObjects = .list(linkedObjectsDetails)
        } else {
            let gridItems = gridLayoutBuilder.makeGridRows(countItems: linkedObjectsDetails.count)
            var prevIndex = 0
            let items = gridItems.map { itemsCount in
                let nextIndex = prevIndex + itemsCount
                let items = linkedObjectsDetails[prevIndex..<nextIndex]
                prevIndex = nextIndex
                return Array(items)
            }
            linkedObjects = .grid(items)
        }
    }
}
