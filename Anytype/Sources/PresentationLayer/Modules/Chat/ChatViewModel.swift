import Foundation
import Services
import SwiftUI
import PhotosUI
import AnytypeCore
import Collections
import UIKit
import NotificationsCore
@preconcurrency import Combine

@MainActor
final class ChatViewModel: ObservableObject, MessageModuleOutput, ChatActionProviderHandler {
    
    // MARK: - DI
    
    let spaceId: String
    let chatId: String
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
    @Injected(\.iconColorService)
    private var iconColorService: any IconColorServiceProtocol
    @Injected(\.bookmarkService)
    private var bookmarkService: any BookmarkServiceProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.pushNotificationsAlertHandler)
    private var pushNotificationsAlertHandler: any PushNotificationsAlertHandlerProtocol
    @Injected(\.notificationsCenterService)
    private var notificationsCenterService: any NotificationsCenterServiceProtocol
    
    private let participantSubscription: any ParticipantsSubscriptionProtocol
    private let chatStorage: any ChatMessagesStorageProtocol
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    private let chatMessageBuilder: any ChatMessageBuilderProtocol
    private let chatObject: any BaseDocumentProtocol
    
    // MARK: - State
    
    // Global
    
    @Published var dataLoaded = false
    @Published var canEdit = false
    var keyboardDismiss: KeyboardDismiss?
    
    // Input Message
    
    @Published var message = NSAttributedString()
    @Published var inputFocused = false
    @Published var replyToMessage: ChatInputReplyModel?
    @Published var editMessage: ChatMessage?
    @Published var sendMessageTaskInProgress: Bool = false
    @Published var sendButtonIsLoading: Bool = false
    @Published var messageTextLimit: String?
    @Published var textLimitReached = false
    @Published var typesForCreateObject: [ObjectType] = []
    @Published var participantSpaceView: ParticipantSpaceViewData?
    
    // Actions
    @Published var actionModel: ChatActionPanelModel = .hidden
    
    // Attachment Handler
    let attachmentHandler: any ChatAttachmentHandlerProtocol
    
    // Attachment Handler Published State
    @Published var linkedObjects: [ChatLinkedObject] = []
    @Published var attachmentsDownloading: Bool = false
    @Published var photosItemsTask = UUID()
    
    // List
    
    @Published var mentionSearchState = ChatTextMention.finish
    @Published var mesageBlocks: [MessageSectionData] = []
    @Published var mentionObjectsModels: [MentionObjectModel] = []
    @Published var collectionViewScrollProxy = ChatCollectionScrollProxy()
    @Published var messageYourBackgroundColor: Color = .Background.Chat.bubbleYour
    @Published var messageHiglightId: String = ""
    
    private var messages: [FullChatMessage] = []
    private var chatState: ChatState?
    private var participants: [Participant] = []
    private var firstUnreadMessageOrderId: String?
    private var bottomVisibleOrderId: String?
    private var bigDistanceToBottom: Bool = false
    private var forceHiddenActionPanel: Bool = true
    private var showScreenLogged = false
    
    var showEmptyState: Bool { mesageBlocks.isEmpty && dataLoaded }
    var conversationType: ConversationType {
        participantSpaceView?.spaceView.uxType.asConversationType ?? .chat
    }
    var participantPermissions: ParticipantPermissions? { participantSpaceView?.participant?.permission }

    // Alerts
    
    @Published var deleteMessageConfirmation: MessageViewData?
    @Published var showSendLimitAlert = false
    @Published var toastBarData: ToastBarData?
    
    init(spaceId: String, chatId: String, output: (any ChatModuleOutput)?) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.output = output
        self.chatStorage = Container.shared.chatMessageStorage((spaceId, chatId))
        self.chatMessageBuilder = ChatMessageBuilder(spaceId: spaceId, chatId: chatId)
        self.participantSubscription = Container.shared.participantSubscription(spaceId)
        // Open object. Middleware will know that we are using the object and will be make a refresh after open from background
        self.chatObject = openDocumentProvider.document(objectId: chatId, spaceId: spaceId)
        self.attachmentHandler = ChatAttachmentHandler(spaceId: spaceId)
        
        setupAttachmentHandler()
    }
    
    private func setupAttachmentHandler() {
        // Subscribe to attachment handler publishers
        attachmentHandler.linkedObjectsPublisher
            .assign(to: &$linkedObjects)
        
        attachmentHandler.attachmentsDownloadingPublisher
            .assign(to: &$attachmentsDownloading)
        
        attachmentHandler.photosItemsTaskPublisher
            .assign(to: &$photosItemsTask)
    }
    
    func onAppear() {
        guard FeatureFlags.removeMessagesFromNotificationsCenter else { return }
        notificationsCenterService.removeDeliveredNotifications(chatId: chatId)
    }
    
    func onTapAddObjectToMessage() {
        AnytypeAnalytics.instance().logClickScreenChatAttach(type: .pagesLists)
        let data = ObjectSearchWithMetaModuleData(
            spaceId: spaceId,
            excludedObjectIds: linkedObjects.compactMap { $0.uploadedObject?.id },
            onSelect: { [weak self] details in
                guard let self else { return }
                do {
                    try attachmentHandler.addUploadedObject(MessageAttachmentDetails(details: details))
                } catch {
                    handleAttachmentError(error)
                }
            }
        )
        output?.onLinkObjectSelected(data: data)
    }
    
    func onTapAddMediaToMessage() {
        AnytypeAnalytics.instance().logClickScreenChatAttach(type: .photo)
        let currentPhotosItems = attachmentHandler.getPhotosItems()
        let data = ChatPhotosPickerData(selectedItems: currentPhotosItems) { [weak self] result in
            guard let self else { return }
            do {
                try attachmentHandler.setPhotosItems(result)
            } catch {
                handleAttachmentError(error)
            }
        }
        output?.onPhotosPickerSelected(data: data)
    }
    
    func onTapAddFilesToMessage() {
        AnytypeAnalytics.instance().logClickScreenChatAttach(type: .file)
        let data = FilesPickerData(handler: { [weak self] result in
            guard let self else { return }
            do {
                try attachmentHandler.handleFilePicker(result: result)
            } catch {
                handleAttachmentError(error)
            }
        })
        output?.onFilePickerSelected(data: data)
    }
    
    func onTapCamera() {
        AnytypeAnalytics.instance().logClickScreenChatAttach(type: .camera)
        let data = SimpleCameraData(onMediaTaken: { [weak self] media in
            guard let self else { return }
            do {
                try attachmentHandler.handleCameraMedia(media)
            } catch {
                handleAttachmentError(error)
            }
        })
        output?.onShowCameraSelected(data: data)
    }
    
    func onTapWidgets() {
        output?.onWidgetsSelected()
    }
    
    func onTapInviteLink() {
        output?.onInviteLinkSelected()
    }
    
    func startSubscriptions() async {
        async let permissionsSub: () = subscribeOnPermissions()
        async let participantsSub: () = subscribeOnParticipants()
        async let typesSub: () = subscribeOnTypes()
        async let messageBackgroundSub: () = subscribeOnMessageBackground()
        async let spaceViewSub: () = subscribeOnSpaceView()
        
        (_, _, _, _, _) = await (permissionsSub, participantsSub, typesSub, messageBackgroundSub, spaceViewSub)
    }
    
    func subscribeOnMessages() async throws {
        try await chatStorage.startSubscriptionIfNeeded()
        for await updates in chatStorage.updateStream {
            
            let chatState = await chatStorage.chatState
            let messages = await chatStorage.fullMessages
            
            if !showScreenLogged {
                AnytypeAnalytics.instance().logScreenChat(
                    unreadMessageCount: chatState?.messages.counter,
                    hasMention: chatState.map { $0.mentions.counter > 0 }
                )
                showScreenLogged = true
            }
            
            if updates.contains(.messages), let messages {
                
                let prevChatIsEmpty = self.messages.isEmpty
                
                self.messages = messages
                self.dataLoaded = true
                if prevChatIsEmpty {
                    firstUnreadMessageOrderId = chatState?.messages.oldestOrderID
                }
                await updateMessages()
                if prevChatIsEmpty {
                    if let oldestOrderId = chatState?.messages.oldestOrderID, let message = messages.first(where: { $0.message.orderID == oldestOrderId}) {
                        collectionViewScrollProxy.scrollTo(itemId: message.message.id, position: .center, animated: false)
                    } else if let message = messages.last {
                        collectionViewScrollProxy.scrollTo(itemId: message.message.id, position: .bottom, animated: false)
                    }
                }
            }
            
            if updates.contains(.state), let chatState {
                self.chatState = chatState
                updateActions()
            }
        }
    }
    
    func onTapSendMessage() {
        sendMessageTaskInProgress = true
    }
    
    func sendMessageTask() async throws {
        guard sendMessageTaskInProgress else { return }
        let loadingTask = Task {
            try await Task.sleep(seconds: 0.3)
            try Task.checkCancellation()
            sendButtonIsLoading = true
        }
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
            let type: SentMessageType = linkedObjects.isNotEmpty ? (message.string.isNotEmpty ? .mixed : .attachment) : .text
            AnytypeAnalytics.instance().logSentMessage(type: type)
            collectionViewScrollProxy.scrollTo(itemId: messageId, position: .bottom, animated: true)
            chatMessageLimits.markSentMessage()
            clearInput()
        } else {
            keyboardDismiss?()
            showSendLimitAlert = true
        }
        loadingTask.cancel()
        sendButtonIsLoading = false
        sendMessageTaskInProgress = false
    }
    
    func onTapRemoveLinkedObject(linkedObject: ChatLinkedObject) {
        withAnimation {
            attachmentHandler.removeLinkedObject(linkedObject)
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
        let mentionString = NSMutableAttributedString(string: mention.name, attributes: [
            .chatMention: mention
        ])
        mentionString.append(NSAttributedString(string: " "))
        
        newMessage.replaceCharacters(in: mentionRange, with: mentionString)
        message = newMessage
        AnytypeAnalytics.instance().logMention()
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
            route: .link,
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
    
    func onLinkAdded(link: URL) {
        attachmentHandler.handleLinkAdded(link: link)
    }
    
    func onPasteAttachmentsFromBuffer(items: [NSItemProvider]) {
        Task {
            do {
                try await attachmentHandler.handlePasteAttachmentsFromBuffer(items: items)
            } catch {
                handleAttachmentError(error)
            }
        }
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
        do {
            try await attachmentHandler.updatePickerItems()
        } catch {
            handleAttachmentError(error)
        }
    }
    
    func deleteMessage(message: MessageViewData) async throws {
        try await chatService.deleteMessage(chatObjectId: chatId, messageId: message.message.id)
    }
    
    func visibleRangeChanged(from: MessageSectionItem, to: MessageSectionItem) {
        guard let fromMessage = from.messageData, let toMessage = to.messageData else { return }
        Task {
            bottomVisibleOrderId = toMessage.message.orderID
            forceHiddenActionPanel = false // Without update panel. Waiting middleware event.
            await chatStorage.updateVisibleRange(startMessageId: fromMessage.message.id, endMessageId: toMessage.message.id)
        }
    }
    
    func bigDistanceToTheBottomChanged(isBig: Bool) {
        bigDistanceToBottom = isBig
        updateActions()
    }
    
    func messageDidChanged() {
        textLimitReached = chatMessageLimits.textIsLimited(text: message)
        messageTextLimit = chatMessageLimits.textIsWarinig(text: message) ? "\(message.string.count) / \(chatMessageLimits.textLimit)" : nil
    }
    
    func configureProvider(_ provider: Binding<ChatActionProvider>) {
        provider.wrappedValue.handler = self
    }
    
    private func handleAttachmentError(_ error: any Error) {
        let errorString: String
        
        if let attachmentError = error as? AttachmentError {
            errorString = attachmentError.localizedError(attachmentsLimit: chatMessageLimits.attachmentsLimit)
        } else {
            errorString = error.localizedDescription
        }
        
        toastBarData = ToastBarData(errorString, type: .failure)
    }
    
    func onTapCreateObject(type: ObjectType) {
        AnytypeAnalytics.instance().logClickScreenChatAttach(type: .object, objectType: type)
        output?.didSelectCreateObject(type: type)
    }
    
    func onTapScrollToBottom() {
        AnytypeAnalytics.instance().logClickScrollToBottom()
        if let bottomVisibleOrderId, let chatState, let firstUnreadMessageOrderId,
            firstUnreadMessageOrderId > bottomVisibleOrderId,
            bottomVisibleOrderId < chatState.messages.oldestOrderID {
            // Scroll to unread messages if user above on it
            Task {
                let message = try await chatStorage.loadPagesTo(orderId: chatState.messages.oldestOrderID)
                collectionViewScrollProxy.scrollTo(itemId: message.id, position: .center, animated: true)
            }
        } else {
            // Scroll to bottom if unser inside unread section
            Task {
                let lastMessage = try await chatStorage.markAsReadAll()
                try await chatStorage.loadPagesTo(messageId: lastMessage.id)
                collectionViewScrollProxy.scrollTo(itemId: lastMessage.id, position: .bottom, animated: true)
            }
        }
    }
    
    func onTapMention() {
        guard let chatState else { return }
        AnytypeAnalytics.instance().logClickScrollToMention()
        Task {
            let message = try await chatStorage.loadPagesTo(orderId: chatState.mentions.oldestOrderID)
            collectionViewScrollProxy.scrollTo(itemId: message.id, position: .center, animated: true)
            messageHiglightId = message.id
        }
    }
    
    func onTapDismissKeyboard() {
        inputFocused = false
    }
    
    // MARK: - MessageModuleOutput
    
    func didSelectAddReaction(messageId: String) {
        AnytypeAnalytics.instance().logClickMessageMenuReaction()
        output?.didSelectAddReaction(messageId: messageId)
    }
    
    func didTapOnReaction(data: MessageViewData, emoji: String) async throws {
        let added = try await chatService.toggleMessageReaction(chatObjectId: data.chatId, messageId: data.message.id, emoji: emoji)
        AnytypeAnalytics.instance().logToggleReaction(added: added)
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
    
    func didSelectAttachment(data: MessageViewData, details: ObjectDetails) {
        didSelectAttachment(attachment: details, attachments: [])
    }
    
    func didSelectReplyTo(message: MessageViewData) {
        AnytypeAnalytics.instance().logClickMessageMenuReply()
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
        AnytypeAnalytics.instance().logClickScrollToReply()
        Task {
            try await chatStorage.loadPagesTo(messageId: reply.id)
            collectionViewScrollProxy.scrollTo(itemId: reply.id)
            messageHiglightId = reply.id
        }
    }
    
    func didSelectDeleteMessage(message: MessageViewData) {
        AnytypeAnalytics.instance().logClickMessageMenuDelete()
        deleteMessageConfirmation = message
    }
    
    func didSelectEditMessage(message messageToEdit: MessageViewData) async {
        AnytypeAnalytics.instance().logClickMessageMenuEdit()
        clearInput()
        editMessage = messageToEdit.message
        message = await chatInputConverter.convert(content: messageToEdit.message.message, spaceId: spaceId).value
        let attachments = await chatStorage.attachments(message: messageToEdit.message)
        let messageAttachments = attachments.map { MessageAttachmentDetails(details: $0) }.sorted { $0.id > $1.id }
        attachmentHandler.setLinkedObjects(messageAttachments.map { .uploadedObject($0) })
    }
    
    func didSelectAuthor(authorId: String) {
        output?.onObjectSelected(screenData: .alert(.spaceMember(ObjectInfo(objectId: authorId, spaceId: spaceId))))
    }
    
    func didSelectUnread(message: MessageViewData) async throws {
        try await chatService.unreadMessage(chatObjectId: chatId, afterOrderId: message.message.orderID, type: .messages)
        try await chatService.unreadMessage(chatObjectId: chatId, afterOrderId: message.message.orderID, type: .mentions)
    }

    func didSelectCopyPlainText(message: MessageViewData) {
        AnytypeAnalytics.instance().logClickMessageMenuCopy()
        UIPasteboard.general.string = NSAttributedString(message.messageString).string
    }
    
    // MARK: - ChatActionProviderHandler
    
    func addAttachment(_ attachment: ChatLinkObject, clearInput needsClearInput: Bool) {
        Task {
            let results = try await searchService.searchObjects(spaceId: attachment.spaceId, objectIds: [attachment.objectId])
            guard let first = results.first else { return }
            if needsClearInput {
                clearInput()
            }
            if attachmentHandler.canAddOneAttachment() {
                do {
                    try attachmentHandler.addUploadedObject(MessageAttachmentDetails(details: first))
                    // Waiting pop transaction and open keyboard.
                    try await Task.sleep(seconds: 1.0)
                    inputFocused = true
                } catch {
                    handleAttachmentError(error)
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func subscribeOnParticipants() async {
        for await participants in participantSubscription.participantsPublisher.values {
            self.participants = participants
            await updateMessages()
        }
    }
    
    private func subscribeOnPermissions() async {
        for await canEditMessages in accountParticipantsStorage.canEditPublisher(spaceId: spaceId).values {
            canEdit = canEditMessages
        }
    }
    
    private func subscribeOnTypes() async {
        for await types in objectTypeProvider.objectTypesPublisher(spaceId: spaceId).values {
            self.typesForCreateObject = types.filter(\.canCreateInChat)
        }
    }
    
    private func subscribeOnMessageBackground() async {
        for await color in iconColorService.color(spaceId: spaceId) {
            messageYourBackgroundColor = color
        }
    }
    
    private func subscribeOnSpaceView() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            self.participantSpaceView = participantSpaceView
            await handlePushNotificationsAlert()
        }
    }
    
    private func updateMessages() async {
        let newMessageBlocks = await chatMessageBuilder.makeMessage(
            messages: messages,
            participants: participants,
            firstUnreadMessageOrderId: firstUnreadMessageOrderId,
            limits: chatMessageLimits
        )
        guard newMessageBlocks != mesageBlocks else { return }
        mesageBlocks = newMessageBlocks
    }
    
    
    
    private func clearInput() {
        message = NSAttributedString()
        attachmentHandler.clearState()
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
        if attachment.resolvedLayoutValue.isFileOrMedia {
            let reorderedAttachments = attachments.sorted { $0.id > $1.id }
            output?.onObjectSelected(screenData: .preview(
                MediaFileScreenData(selectedItem: attachment, allItems: reorderedAttachments, route: .chat)
            ))
        } else {
            output?.onObjectSelected(screenData: attachment.screenData())
        }
    }
    
    private func handlePushNotificationsAlert() async {
        guard await pushNotificationsAlertHandler.shouldShowAlert() else { return }
        output?.onPushNotificationsAlertSelected()
    }
    
    private func updateActions() {
        if let chatState, !forceHiddenActionPanel {
            actionModel = ChatActionPanelModel(
                showScrollToBottom: chatState.messages.counter > 0 || bigDistanceToBottom,
                srollToBottomCounter: Int(chatState.messages.counter),
                showMentions: chatState.mentions.counter > 0,
                mentionsCounter: Int(chatState.mentions.counter)
            )
        } else {
            actionModel = ChatActionPanelModel(
                showScrollToBottom: bigDistanceToBottom,
                srollToBottomCounter: 0,
                showMentions: false,
                mentionsCounter: 0
            )
        }
    }
}
