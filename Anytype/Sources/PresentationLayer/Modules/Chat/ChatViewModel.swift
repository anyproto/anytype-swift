import Foundation
import Services
import SwiftUI
import PhotosUI
import AnytypeCore
import Collections

@MainActor
final class ChatViewModel: ObservableObject, MessageModuleOutput {
    
    // MARK: - DI
    
    private let spaceId: String
    let objectId: String
    private let chatId: String
    private weak var output: (any ChatModuleOutput)?
    
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.mentionObjectsService)
    private var mentionObjectsService: any MentionObjectsServiceProtocol
    @Injected(\.chatActionService)
    private var chatActionService: any ChatActionServiceProtocol
    @Injected(\.fileActionsService)
    private var fileActionsService: any FileActionsServiceProtocol
    
    private lazy var participantSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(spaceId)
    private lazy var chatStorage: any ChatMessagesStorageProtocol = Container.shared.chatMessageStorage((spaceId, chatId))
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    
    // MARK: - State
    
    private let document: any BaseDocumentProtocol
    
    @Published var linkedObjects: [ChatLinkedObject] = []
    @Published var mesageBlocks: [MessageViewData] = []
    @Published var collectionViewScrollProxy = ChatCollectionScrollProxy()
    @Published var message = NSAttributedString()
    @Published var canEdit = false
    @Published var title = ""
    @Published var syncStatusData = SyncStatusData(status: .offline, networkId: "", isHidden: true)
    @Published var objectIcon: Icon?
    @Published var inputFocused = false
    @Published var dataLoaded = false
    @Published var mentionSearchState = ChatTextMention.finish
    @Published var mentionObjects: [MentionObject] = []
    @Published var photosItemsTask = UUID()
    @Published var attachmentsDownloading: Bool = false
    @Published var replyToMessage: ChatInputReplyModel?
    
    var showTitleData: Bool { mesageBlocks.isNotEmpty }
    var showEmptyState: Bool { mesageBlocks.isEmpty && dataLoaded }
    
    private var messages: [ChatMessage] = []
    private var participants: [Participant] = []
    private var photosItems: [PhotosPickerItem] = []
    
    init(objectId: String, spaceId: String, chatId: String, output: (any ChatModuleOutput)?) {
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
    
    func onSyncStatusTap() {
        output?.onSyncStatusSelected()
    }
    
    func onSettingsTap() {
        output?.onSettingsSelected()
    }
    
    func didTapIcon() {
        output?.onIconSelected()
    }
    
    func updateMentionState() async throws {
        switch mentionSearchState {
        case let .search(searchText, _):
            mentionObjects = try await mentionObjectsService.searchMentions(spaceId: spaceId, text: searchText, limitLayout: [.participant])
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
    
    func didSelectObject(details: MessageAttachmentDetails) {
        let screenData = details.editorScreenData
        output?.onObjectSelected(screenData: screenData)
    }
    
    func didSelectReplyTo(message: MessageViewData) {
        withAnimation {
            replyToMessage = ChatInputReplyModel(
                id: message.message.id,
                title: Loc.Chat.replyTo(message.participant?.title ?? ""),
                description: MessageTextBuilder.makeMessage(content: message.message.message, font: .caption1Regular),
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
        
        let yourProfileIdentity = accountParticipantsStorage.participants.first?.identity
        
        let newMessageBlocks = await messages.asyncMap { message -> MessageViewData in
            
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
                objectId: objectId,
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
