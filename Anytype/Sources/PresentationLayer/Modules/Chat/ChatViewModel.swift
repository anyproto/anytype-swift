import Foundation
import Services
import SwiftUI
import PhotosUI
import AnytypeCore
import Collections
import UIKit

@MainActor
final class ChatViewModel: ObservableObject, MessageModuleOutput {
    
    // MARK: - DI
    
    let spaceId: String
    private let chatId: String
    private weak var output: (any ChatModuleOutput)?
    
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    @Injected(\.mentionObjectsService)
    private var mentionObjectsService: any MentionObjectsServiceProtocol
    @Injected(\.chatActionService)
    private var chatActionService: any ChatActionServiceProtocol
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    private lazy var participantSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(spaceId)
    private let chatStorage: any ChatMessagesStorageProtocol
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    private let chatMessageBuilder: any ChatMessageBuilderProtocol
    
    // MARK: - State
    
    @Published var linkedObjects: [ChatLinkedObject] = []
    @Published var mesageBlocks: [MessageSectionData] = []
    @Published var collectionViewScrollProxy = ChatCollectionScrollProxy()
    @Published var message = NSAttributedString()
    @Published var canEdit = false
    @Published var inputFocused = false
    @Published var dataLoaded = false
    @Published var mentionSearchState = ChatTextMention.finish
    @Published var mentionObjects: [MentionObject] = []
    @Published var photosItemsTask = UUID()
    @Published var attachmentsDownloading: Bool = false
    @Published var replyToMessage: ChatInputReplyModel?
    
    var showEmptyState: Bool { mesageBlocks.isEmpty && dataLoaded }
    
    private var messages: [ChatMessage] = []
    private var participants: [Participant] = []
    private var photosItems: [PhotosPickerItem] = []
    
    init(spaceId: String, chatId: String, output: (any ChatModuleOutput)?) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.output = output
        self.chatStorage = Container.shared.chatMessageStorage((spaceId, chatId))
        self.chatMessageBuilder = ChatMessageBuilder(spaceId: spaceId, chatId: chatId, chatStorage: chatStorage)
    }
    
    func onTapAddObjectToMessage() {
        let data = BlockObjectSearchData(
            title: Loc.linkTo,
            spaceId: spaceId,
            excludedObjectIds: linkedObjects.compactMap { $0.uploadedObject?.id },
            excludedLayouts: [],
            onSelect: { [weak self] details in
                self?.linkedObjects.append(.uploadedObject(MessageAttachmentDetails(details: details)))
            }
        )
        output?.onLinkObjectSelected(data: data)
    }
    
    func onTapAddMediaToMessage() {
        let data = ChatPhotosPickerData(selectedItems: photosItems) { [weak self] result in
            self?.photosItems = result
            self?.photosItemsTask = UUID()
        }
        output?.onPhotosPickerSelected(data: data)
    }
    
    func onTapAddFilesToMessage() {
        let data = ChatFilesPickerData(handler: { [weak self] result in
            self?.handleFilePicker(result: result)
        })
        output?.onFilePickerSelected(data: data)
    }
    
    func subscribeOnParticipants() async {
        for await participants in participantSubscription.participantsPublisher.values {
            self.participants = participants
            await updateMessages()
        }
    }
    
    func subscribeOnPermissions() async {
        for await canEditMessages in accountParticipantsStorage.canEditPublisher(spaceId: spaceId).values {
            canEdit = canEditMessages
        }
    }
    
    func subscribeOnMessages() async throws {
        try await chatStorage.startSubscriptionIfNeeded()
        for await messages in await chatStorage.messagesPublisher.values {
            self.messages = messages
            self.dataLoaded = true
            await updateMessages()
        }
    }
    
    func onTapSendMessage() {
        Task {
            let messageId = try await chatActionService.createMessage(
                chatId: chatId,
                spaceId: spaceId,
                message: message.sendable(),
                linkedObjects: linkedObjects,
                replyToMessageId: replyToMessage?.id
            )
            collectionViewScrollProxy.scrollTo(itemId: messageId, position: .bottom)
            message = NSAttributedString()
            linkedObjects = []
            photosItems = []
            replyToMessage = nil
        }
    }
    
    func onTapRemoveLinkedObject(linkedObject: ChatLinkedObject) {
        withAnimation {
            linkedObjects.removeAll { $0.id == linkedObject.id }
            photosItems.removeAll { $0.hashValue == linkedObject.id }
        }
    }
    
    func scrollToBottom() async {
        try? await chatStorage.loadNextPage()
    }
    
    func updateMentionState() async throws {
        switch mentionSearchState {
        case let .search(searchText, _):
            mentionObjects = try await mentionObjectsService.searchMentions(spaceId: spaceId, text: searchText, excludedObjectIds: [], limitLayout: [.participant])
        case .finish:
            mentionObjects = []
        }
    }
    
    func didSelectMention(_ mention: MentionObject) {
        guard case let .search(_, mentionRange) = mentionSearchState else { return }
        let newMessage = NSMutableAttributedString(attributedString: message)
        let mentionString = NSAttributedString(string: mention.name, attributes: [
            .chatMention: mention
        ])
        
        newMessage.replaceCharacters(in: mentionRange, with: mentionString)
        message = newMessage
    }
    
    func didSelectObject(linkedObject: ChatLinkedObject) {
        guard let details = linkedObject.uploadedObject else { return }
        let screenData = details.editorScreenData
        output?.onObjectSelected(screenData: screenData)
    }
    
    func onTapLinkTo(range: NSRange) {
        let currentLinkToURL = message.attribute(.chatLinkToURL, at: range.location, effectiveRange: nil) as? URL
        let currentLinkToObject = message.attribute(.chatLinkToObject, at: range.location, effectiveRange: nil) as? String
        let data = LinkToObjectSearchModuleData(
            spaceId: spaceId,
            currentLinkUrl: currentLinkToURL,
            currentLinkString: currentLinkToObject,
            setLinkToObject: { [weak self] in
                guard let self else { return }
                let newMessage = NSMutableAttributedString(attributedString: message)
                newMessage.addAttribute(.chatLinkToObject, value: $0, range: range)
                message = newMessage
            },
            setLinkToUrl: { [weak self] in
                guard let self else { return }
                let newMessage = NSMutableAttributedString(attributedString: message)
                newMessage.addAttribute(.chatLinkToURL, value: $0, range: range)
                message = newMessage
            },
            removeLink: { [weak self] in
                guard let self else { return }
                let newMessage = NSMutableAttributedString(attributedString: message)
                newMessage.removeAttribute(.chatLinkToURL, range: range)
                newMessage.removeAttribute(.chatLinkToObject, range: range)
                message = newMessage
            },
            willShowNextScreen: nil
        )
        output?.didSelectLinkToObject(data: data)
    }
    
    func onTapDeleteReply() {
        withAnimation {
            replyToMessage = nil
        }
    }
    
    func updatePickerItems() async {
        attachmentsDownloading = true
        defer { attachmentsDownloading = false }
        
        let newItemsIds = Set(photosItems.map(\.hashValue))
        let linkedIds = Set(linkedObjects.compactMap(\.localPhotosFile?.photosPickerItemHash))
        let removeIds = linkedIds.subtracting(newItemsIds)
        let addIds = newItemsIds.subtracting(linkedIds)
        
        // Remove old
        linkedObjects.removeAll { removeIds.contains($0.id) }
        // Add new in loading state
        let newItems = photosItems.filter { addIds.contains($0.hashValue) }
        
        let newLinkedObjects = newItems.map {
            ChatLinkedObject.localPhotosFile(
                ChatLocalPhotosFile(data: nil, photosPickerItemHash: $0.hashValue)
            )
        }
        linkedObjects.append(contentsOf: newLinkedObjects)
        
        for photosItem in newItems {
            do {
                let data = try await fileActionsService.createFileData(photoItem: photosItem)
                let linkeObject = ChatLinkedObject.localPhotosFile(
                    ChatLocalPhotosFile(data: data, photosPickerItemHash: photosItem.hashValue)
                )
                if let index = linkedObjects.firstIndex(where: { $0.id == photosItem.hashValue }) {
                    linkedObjects[index] = linkeObject
                } else {
                    linkedObjects.append(linkeObject)
                    anytypeAssertionFailure("Linked object should be added in loading state")
                }
            } catch {
                linkedObjects.removeAll { $0.id == photosItem.hashValue }
                photosItems.removeAll { $0 == photosItem }
            }
        }
    }
    
    // MARK: - MessageModuleOutput
    
    func didSelectAddReaction(messageId: String) {
        output?.didSelectAddReaction(messageId: messageId)
    }
    
    func didLongTapOnReaction(data: MessageParticipantsReactionData) {
        output?.didLongTapOnReaction(data: data)
    }
    
    func didSelectObject(details: MessageAttachmentDetails) {
        let screenData = details.editorScreenData
        output?.onObjectSelected(screenData: screenData)
    }
    
    func didSelectReplyTo(message: MessageViewData) {
        withAnimation {
            replyToMessage = ChatInputReplyModel(
                id: message.message.id,
                title: Loc.Chat.replyTo(message.participant?.title ?? ""),
                // Without style. Request from designers.
                description: MessageTextBuilder.makeMessaeWithoutStyle(content: message.message.message),
                icon: message.attachmentsDetails.first?.objectIconImage
            )
        }
    }
    
    func didSelectReplyMessage(message: MessageViewData) {
        guard let reply = message.reply else { return }
        Task {
            try await chatStorage.loadPagesTo(messageId: reply.id)
            collectionViewScrollProxy.scrollTo(itemId: reply.id)
        }
    }
    
    // MARK: - Private
    
    private func updateMessages() async {
        let newMessageBlocks = await chatMessageBuilder.makeMessage(messages: messages, participants: participants)
        guard newMessageBlocks != mesageBlocks else { return }
        mesageBlocks = newMessageBlocks
    }
    
    private func handleFilePicker(result: Result<[URL], any Error>) {
        switch result {
        case .success(let files):
            files.forEach { file in
                let gotAccess = file.startAccessingSecurityScopedResource()
                guard gotAccess else { return }
                
                if let fileData = try? fileActionsService.createFileData(fileUrl: file) {
                    linkedObjects.append(.localBinaryFile(fileData))
                }
                
                file.stopAccessingSecurityScopedResource()
            }
        case .failure:
            break
        }
    }
}
