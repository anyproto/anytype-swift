import Foundation
import Services
import SwiftUI

@MainActor
final class DiscussionViewModel: ObservableObject, MessageModuleOutput {
    
    // MARK: - DI
    
    private let spaceId: String
    let objectId: String
    private let chatId: String
    private weak var output: (any DiscussionModuleOutput)?
    
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    private lazy var participantSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(spaceId)
    private lazy var chatStorage: any ChatMessagesStorageProtocol = Container.shared.chatMessageStorage(chatId)
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    
    // MARK: - State
    
    private let document: any BaseDocumentProtocol
    
    @Published var linkedObjects: [ObjectDetails] = []
    @Published var mesageBlocks: [MessageViewData] = []
    @Published var messagesScrollUpdate: DiscussionCollectionDiffApply = .auto
    @Published var message: AttributedString = ""
    @Published var canEdit = false
    @Published var title = ""
    @Published var syncStatusData = SyncStatusData(status: .offline, networkId: "", isHidden: true)
    @Published var objectIcon: Icon?
    @Published var inputFocused = false
    @Published var dataLoaded = false
    var showTitleData: Bool { mesageBlocks.isNotEmpty }
    var showEmptyState: Bool { mesageBlocks.isEmpty && dataLoaded }
    
    private var messages: [ChatMessage] = []
    private var participants: [Participant] = []
    private var scrollToLastForNextUpdate = false
    
    init(objectId: String, spaceId: String, chatId: String, output: (any DiscussionModuleOutput)?) {
        self.spaceId = spaceId
        self.objectId = objectId
        self.chatId = chatId
        self.output = output
        self.document = openDocumentProvider.document(objectId: objectId)
    }
    
    func onTapAddObjectToMessage() {
        let data = BlockObjectSearchData(
            title: Loc.linkTo,
            spaceId: spaceId,
            excludedObjectIds: linkedObjects.map(\.id),
            excludedLayouts: [],
            onSelect: { [weak self] details in
                self?.linkedObjects.append(details)
            }
        )
        output?.onLinkObjectSelected(data: data)
    }
    
    func subscribeOnParticipants() async {
        for await participants in participantSubscription.participantsPublisher.values {
            self.participants = participants
            updateMessages()
        }
    }
    
    func subscribeOnPermissions() async {
        for await permissions in document.permissionsPublisher.values {
            canEdit = permissions.canEditMessages
        }
    }
    
    func subscribeOnDetails() async {
        for await details in document.detailsPublisher.values {
            title = details.title
            objectIcon = details.objectIconImage
        }
    }
    
    func subscribeOnSyncStatus() async {
        for await status in document.syncStatusDataPublisher.values {
            syncStatusData = SyncStatusData(status: status.syncStatus, networkId: accountManager.account.info.networkId, isHidden: false)
        }
    }
    
    func loadNextPage() {
        Task {
            try await chatStorage.loadNextPage()
        }
    }
    
    func subscribeOnMessages() async throws {
        try await chatStorage.startSubscription()
        for await messages in await chatStorage.messagesPublisher.values {
            self.messages = messages
            self.dataLoaded = true
            updateMessages()
            scrollToLastForNextUpdate = false
        }
    }
    
    func onTapSendMessage() {
        Task {
            var chatMessage = ChatMessage()
            chatMessage.message.text = String(message.characters)
            chatMessage.attachments = linkedObjects.map { details in
                var attachment = ChatMessageAttachment()
                attachment.target = details.id
                attachment.type = .link
                return attachment
            }
            try await chatService.addMessage(chatObjectId: chatId, message: chatMessage)
            scrollToLastForNextUpdate = true
            message = AttributedString()
            linkedObjects = []
        }
    }
    
    func onTapRemoveLinkedObject(details: ObjectDetails) {
        withAnimation {
            linkedObjects.removeAll { $0.id == details.id }
        }
    }
    
    func didSelectAddReaction(messageId: String) {
        output?.didSelectAddReaction(messageId: messageId)
    }
    
    func scrollToBottom() async {
        try? await chatStorage.loadNextPage()
    }
    
    func onSyncStatusTap() {
        output?.onSyncStatusSelected()
    }
    
    func onSettingsTap() {
        output?.onSettingsSelected()
    }
    
    func didTapIcon() {
        output?.onIconSelected()
    }
    
    // MARK: - Private
    
    private func updateMessages() {
        
        let yourProfileIdentity = accountParticipantsStorage.participants.first?.identity
        
        let newMessageBlocks = messages.compactMap { message -> MessageViewData in
            
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
            
            return MessageViewData(
                spaceId: spaceId,
                objectId: objectId,
                chatId: chatId,
                message: message,
                participant: participants.first { $0.identity == message.creator },
                reactions: reactions
            )
        }
        
        guard newMessageBlocks != mesageBlocks else { return }
        mesageBlocks = newMessageBlocks
        
        if scrollToLastForNextUpdate {
            messagesScrollUpdate = .scrollToLast
        } else {
            messagesScrollUpdate = .auto
        }
    }
}
