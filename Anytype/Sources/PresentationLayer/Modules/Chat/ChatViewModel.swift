import Foundation
import Services
import SwiftUI
import PhotosUI
import AnytypeCore
import Collections
import UIKit
@preconcurrency import Combine

@MainActor
final class ChatViewModel: ObservableObject, MessageModuleOutput, ChatActionProviderHandler {
    
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
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    @Injected(\.chatInputConverter)
    private var chatInputConverter: any ChatInputConverterProtocol
    @Injected(\.chatMessageLimits)
    private var chatMessageLimits: any ChatMessageLimitsProtocol
    @Injected(\.messageTextBuilder)
    private var messageTextBuilder: any MessageTextBuilderProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    private lazy var participantSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(spaceId)
    private let chatStorage: any ChatMessagesStorageProtocol
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    private let chatMessageBuilder: any ChatMessageBuilderProtocol
    
    // MARK: - State
    
    // Global
    
    @Published var dataLoaded = false
    @Published var canEdit = false
    var keyboardDismiss: KeyboardDismiss?
    
    // Input Message
    
    @Published var linkedObjects: [ChatLinkedObject] = []
    @Published var message = NSAttributedString()
    @Published var inputFocused = false
    @Published var photosItemsTask = UUID()
    @Published var attachmentsDownloading: Bool = false
    @Published var replyToMessage: ChatInputReplyModel?
    @Published var editMessage: ChatMessage?
    @Published var sendMessageTaskInProgress: Bool = false
    @Published var messageTextLimit: String?
    @Published var textLimitReached = false
    @Published var typesForCreateObject: [ObjectType] = []
    private var photosItems: [PhotosPickerItem] = []
    
    // List
    
    @Published var mentionSearchState = ChatTextMention.finish
    @Published var mesageBlocks: [MessageSectionData] = []
    @Published var mentionObjectsModels: [MentionObjectModel] = []
    @Published var collectionViewScrollProxy = ChatCollectionScrollProxy()
    
    private var messages: [FullChatMessage] = []
    private var participants: [Participant] = []
    
    var showEmptyState: Bool { mesageBlocks.isEmpty && dataLoaded }

    // Alerts
    
    @Published var deleteMessageConfirmation: MessageViewData?
    @Published var showSendLimitAlert = false
    @Published var toastBarData: ToastBarData = .empty
    
    init(spaceId: String, chatId: String, output: (any ChatModuleOutput)?) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.output = output
        self.chatStorage = Container.shared.chatMessageStorage((spaceId, chatId))
        self.chatMessageBuilder = ChatMessageBuilder(spaceId: spaceId, chatId: chatId)
    }
    
    func onTapAddPageToMessage() {
        let data = buildObjectSearcData(type: .pages)
        output?.onLinkObjectSelected(data: data)
    }
    
    func onTapAddListToMessage() {
        let data = buildObjectSearcData(type: .lists)
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
    
    func onTapCamera() {
        let data = SimpleCameraData(onMediaTaken: { [weak self] media in
            self?.handleCameraMedia(media)
        })
        output?.onShowCameraSelected(data: data)
    }
    
    func onTapWidgets() {
        output?.onWidgetsSelected()
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
            let prevChatIsEmpty = self.messages.isEmpty
            self.messages = messages
            self.dataLoaded = true
            await updateMessages()
            if prevChatIsEmpty, let message = messages.last {
                collectionViewScrollProxy.scrollTo(itemId: message.message.id, position: .bottom, animated: false)
            }
        }
    }
    
    func subscribeOnTypes() async {
        for await _ in objectTypeProvider.syncPublisher.values {
            let objectTypesCreateInChat = objectTypeProvider.objectTypes(spaceId: spaceId).filter(\.canCreateInChat)
            let usedObjecTypesKeys = ObjectSearchWithMetaType.allCases.flatMap(\.objectTypesCreationKeys)
            self.typesForCreateObject = objectTypesCreateInChat.filter { !usedObjecTypesKeys.contains($0.uniqueKey) }
        }
    }
    
    func onTapSendMessage() {
        sendMessageTaskInProgress = true
    }
    
    func sendMessageTask() async throws {
        guard sendMessageTaskInProgress else { return }
        mentionSearchState = .finish
        if let editMessage {
            try await chatActionService.updateMessage(
                chatId: chatId,
                spaceId: spaceId,
                messageId: editMessage.id,
                message: message.sendable(),
                linkedObjects: linkedObjects,
                replyToMessageId: replyToMessage?.id
            )
            clearInput()
        } else if chatMessageLimits.canSendMessage() {
            let messageId = try await chatActionService.createMessage(
                chatId: chatId,
                spaceId: spaceId,
                message: message.sendable(),
                linkedObjects: linkedObjects,
                replyToMessageId: replyToMessage?.id
            )
            collectionViewScrollProxy.scrollTo(itemId: messageId, position: .bottom, animated: true)
            chatMessageLimits.markSentMessage()
            clearInput()
        } else {
            keyboardDismiss?()
            showSendLimitAlert = true
        }
        sendMessageTaskInProgress = false
    }
    
    func onTapRemoveLinkedObject(linkedObject: ChatLinkedObject) {
        withAnimation {
            linkedObjects.removeAll { $0.id == linkedObject.id }
            photosItems.removeAll { $0.hashValue == linkedObject.id }
        }
    }
    
    func scrollToTop() async {
        try? await chatStorage.loadNextPage()
    }
    
    func scrollToBottom() async {
        try? await chatStorage.loadPrevPage()
    }
    
    func updateMentionState() async throws {
        switch mentionSearchState {
        case let .search(searchText, _):
            let mentionObjects = try await mentionObjectsService.searchMentions(spaceId: spaceId, text: searchText, excludedObjectIds: [], limitLayout: [.participant])
            mentionObjectsModels = handledMentionObjects(mentionObjects)
        case .finish:
            mentionObjectsModels = []
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
        Task {
            let ids = linkedObjects.compactMap { $0.uploadedObject?.id }
            let attachments = await chatStorage.attachments(ids: ids)
            
            guard let selectedAttachment = attachments.first(where: { $0.id == linkedObject.uploadedObject?.id }) else { return }
            
            didSelectAttachment(attachment: selectedAttachment, attachments: attachments)
        }
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
    
    func onTapDeleteEdit() {
        clearInput()
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
        var newItems = photosItems.filter { addIds.contains($0.hashValue) }
        
        // Remove over limit
        let availableItemsCount = chatMessageLimits.countAttachmentsCanBeAdded(current: linkedObjects.count)
        if availableItemsCount < newItems.count {
            let deletedIds = newItems[availableItemsCount..<newItems.count]
            newItems.removeLast(newItems.count - availableItemsCount)
            photosItems.removeAll { deletedIds.contains($0) }
            showFileLimitAlert()
        }
        
        // Add new in loading state
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
    
    func deleteMessage(message: MessageViewData) async throws {
        try await chatService.deleteMessage(chatObjectId: chatId, messageId: message.message.id)
    }
    
    func visibleRangeChanged(fromId: String, toId: String) {
        Task {
            await chatStorage.updateVisibleRange(starMessageId: fromId, endMessageId: toId)
        }
    }
    
    func messageDidChanged() {
        textLimitReached = chatMessageLimits.textIsLimited(text: message)
        messageTextLimit = chatMessageLimits.textIsWarinig(text: message) ? "\(message.string.count) / \(chatMessageLimits.textLimit)" : nil
    }
    
    func configureProvider(_ provider: Binding<ChatActionProvider>) {
        provider.wrappedValue.handler = self
    }
    
    func onTapCreateObject(type: ObjectType) {
        output?.didSelectCreateObject(type: type)
    }
    
    // MARK: - MessageModuleOutput
    
    func didSelectAddReaction(messageId: String) {
        output?.didSelectAddReaction(messageId: messageId)
    }
    
    func didTapOnReaction(data: MessageViewData, reaction: MessageReactionModel) async throws {
        try await chatService.toggleMessageReaction(chatObjectId: data.chatId, messageId: data.message.id, emoji: reaction.emoji)
    }
    
    func didLongTapOnReaction(data: MessageViewData, reaction: MessageReactionModel) {
        let participantsIds = data.message.reactions.reactions[reaction.emoji]?.ids ?? []
        output?.didLongTapOnReaction(
            data: MessageParticipantsReactionData(
                spaceId: data.spaceId,
                emoji: reaction.emoji,
                participantsIds: participantsIds
            )
        )
    }
    
    func didSelectAttachment(data: MessageViewData, details: MessageAttachmentDetails) {
        guard let details = data.attachmentsDetails.first(where: { $0.id == details.id }) else { return }
        didSelectAttachment(attachment: details, attachments: data.attachmentsDetails)
    }
    
    func didSelectReplyTo(message: MessageViewData) {
        withAnimation {
            inputFocused = true
            replyToMessage = ChatInputReplyModel(
                id: message.message.id,
                title: Loc.Chat.replyTo(message.authorName),
                // Without style. Request from designers.
                description: messageTextBuilder.makeMessaeWithoutStyle(content: message.message.message),
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
    
    func didSelectDeleteMessage(message: MessageViewData) {
        deleteMessageConfirmation = message
    }
    
    func didSelectEditMessage(message messageToEdit: MessageViewData) async {
        clearInput()
        editMessage = messageToEdit.message
        message = await chatInputConverter.convert(content: messageToEdit.message.message, spaceId: spaceId).value
        let attachments = await chatStorage.attachments(message: messageToEdit.message)
        let messageAttachments = attachments.map { MessageAttachmentDetails(details: $0) }.sorted { $0.id > $1.id }
        linkedObjects = messageAttachments.map { .uploadedObject($0) }
    }
    
    func didSelectAuthor(authorId: String) {
        output?.onObjectSelected(screenData: .alert(.spaceMember(ObjectInfo(objectId: authorId, spaceId: spaceId))))
    }
    
    // MARK: - ChatActionProviderHandler
    
    func addAttachment(_ attachment: ChatLinkObject, clearInput needsClearInput: Bool) {
        Task {
            let results = try await searchService.searchObjects(spaceId: attachment.spaceId, objectIds: [attachment.objectId])
            guard let first = results.first else { return }
            if needsClearInput {
                clearInput()
            }
            if chatMessageLimits.oneAttachmentCanBeAdded(current: linkedObjects.count) {   
                linkedObjects.append(.uploadedObject(MessageAttachmentDetails(details: first)))
                // Waiting pop transaction and open keyboard.
                try await Task.sleep(seconds: 1.0)
                inputFocused = true
            }
        }
    }
    
    // MARK: - Private
    
    private func updateMessages() async {
        let newMessageBlocks = await chatMessageBuilder.makeMessage(
            messages: messages,
            participants: participants,
            limits: chatMessageLimits
        )
        guard newMessageBlocks != mesageBlocks else { return }
        mesageBlocks = newMessageBlocks
    }
    
    private func handleFilePicker(result: Result<[URL], any Error>) {
        switch result {
        case .success(let files):
            for file in files {
                if !chatMessageLimits.oneAttachmentCanBeAdded(current: linkedObjects.count) {
                    showFileLimitAlert()
                    return
                }
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
    
    private func handleCameraMedia(_ media: ImagePickerMediaType) {
        if !chatMessageLimits.oneAttachmentCanBeAdded(current: linkedObjects.count) {
            showFileLimitAlert()
            return
        }
        switch media {
        case .image(let image, let type):
            if let fileData = try? fileActionsService.createFileData(image: image, type: type) {
                linkedObjects.append(.localBinaryFile(fileData))
            }
        case .video(let file):
            if let fileData = try? fileActionsService.createFileData(fileUrl: file) {
                linkedObjects.append(.localBinaryFile(fileData))
            }
        }
    }
    
    private func clearInput() {
        message = NSAttributedString()
        linkedObjects = []
        photosItems = []
        photosItemsTask = UUID()
        replyToMessage = nil
        editMessage = nil
    }
    
    private func handledMentionObjects(_ mentionObjects: [MentionObject]) -> [MentionObjectModel] {
        let isYourIdentityProfileLink = accountParticipantsStorage.participants.first { $0.spaceId == spaceId }?.identityProfileLink
        return mentionObjects.map { mentionObject in
            let titleBadge = mentionObject.details.identityProfileLink == isYourIdentityProfileLink ? Loc.Chat.Participant.badge : nil
            return MentionObjectModel(object: mentionObject, titleBadge: titleBadge)
        }
    }
    
    private func didSelectAttachment(attachment: ObjectDetails, attachments: [ObjectDetails]) {
        if FeatureFlags.openMediaFileInPreview, attachment.layoutValue.isFileOrMedia {
            let reorderedAttachments = attachments.sorted { $0.id > $1.id }
            let items = reorderedAttachments.compactMap { $0.previewRemoteItem }
            let startAtIndex = items.firstIndex { $0.id == attachment.id } ?? 0
            output?.onObjectSelected(screenData: .preview(MediaFileScreenData(items: items, startAtIndex: startAtIndex)))
        } else if attachment.layoutValue.isBookmark, let url = attachment.source?.url {
            output?.onUrlSelected(url: url)
        } else {
            output?.onObjectSelected(screenData: attachment.screenData())
        }
    }
    
    private func showFileLimitAlert() {
        toastBarData = ToastBarData(text: Loc.Chat.AttachmentsLimit.alert(chatMessageLimits.attachmentsLimit), showSnackBar: true, messageType: .failure)
    }
    
    private func buildObjectSearcData(type: ObjectSearchWithMetaType) -> ObjectSearchWithMetaModuleData {
        ObjectSearchWithMetaModuleData(
            spaceId: spaceId,
            type: type,
            excludedObjectIds: linkedObjects.compactMap { $0.uploadedObject?.id },
            onSelect: { [weak self] details in
                guard let self else { return }
                if chatMessageLimits.oneAttachmentCanBeAdded(current: linkedObjects.count) {
                    linkedObjects.append(.uploadedObject(MessageAttachmentDetails(details: details)))
                } else {
                    showFileLimitAlert()
                }
            }
        )
    }
}
