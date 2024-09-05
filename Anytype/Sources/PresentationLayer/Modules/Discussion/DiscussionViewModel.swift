import Foundation
import Services
import SwiftUI

@MainActor
final class DiscussionViewModel: ObservableObject, MessageModuleOutput {
    
    private let spaceId: String
    private let objectId: String
    private let chatId: String
    private weak var output: (any DiscussionModuleOutput)?
    
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    private lazy var participantSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(spaceId)
    private lazy var chatStorage: any ChatMessagesStorageProtocol = Container.shared.chatMessageStorage(chatId)
    
    @Published var linkedObjects: [ObjectDetails] = []
    @Published var mesageBlocks: [MessageViewData] = []
    @Published var messagesScrollUpdate: DiscussionCollectionDiffApply = .auto
    @Published var message: AttributedString = ""
    
    private var messages: [ChatMessage] = []
    private var participants: [Participant] = []
    private var scrollToLastForNextUpdate = false
    
    init(objectId: String, spaceId: String, chatId: String, output: (any DiscussionModuleOutput)?) {
        self.spaceId = spaceId
        self.objectId = objectId
        self.chatId = chatId
        self.output = output
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
    
    func loadNextPage() {
        Task {
            try await chatStorage.loadNextPage()
        }
    }
    
    func subscribeOnMessages() async throws {
        try await chatStorage.startSubscription()
        for await messages in await chatStorage.messagesPublisher.values {
            self.messages = messages
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
    
    // MARK: - Private
    
    private func updateMessages() {
        
        let newMesageBlocks = messages.compactMap { message  in
            MessageViewData(
                spaceId: spaceId,
                objectId: objectId,
                chatId: chatId,
                message: message,
                participant: participants.first { $0.identity == message.creator }
            )
        }
        
        guard newMesageBlocks != mesageBlocks else { return }
        mesageBlocks = newMesageBlocks
        
        if scrollToLastForNextUpdate {
            messagesScrollUpdate = .scrollToLast
        } else {
            messagesScrollUpdate = .auto
        }
    }
}
