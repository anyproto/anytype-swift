import SwiftUI
import PhotosUI
import AnytypeCore

struct ChatView: View {
    
    @StateObject private var model: ChatViewModel
    @State private var actionState = ChatActionOverlayState()
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    @Environment(\.chatActionProvider) private var chatActionProvider
    
    init(spaceId: String, chatId: String, output: (any ChatModuleOutput)?) {
        self._model = StateObject(wrappedValue: ChatViewModel(spaceId: spaceId, chatId: chatId, output: output))
    }
    
    var body: some View {
        ZStack {
            HomeWallpaperView(spaceId: model.spaceId)
            mainView
                .ignoresSafeArea()
        }
        .overlay(alignment: .top) {
            ChatHeaderView(spaceId: model.spaceId, chatId: model.chatId) {
                model.onTapWidgets()
            }
        }
        .onAppear {
            model.keyboardDismiss = keyboardDismiss
            model.configureProvider(chatActionProvider)
            model.onAppear()
        }
        .ignoresSafeArea(.keyboard)
        .chatActionOverlay(state: $actionState) {
            if model.mentionObjectsModels.isNotEmpty {
                ChatMentionList(models: model.mentionObjectsModels) {
                    model.didSelectMention($0)
                }
            }
        }
        .task {
            await model.startSubscriptions()
        }
        .throwingTask {
            try await model.subscribeOnMessages()
        }
        .task(id: model.photosItemsTask) {
            await model.updatePickerItems()
        }
        .anytypeSheet(item: $model.deleteMessageConfirmation) {
            ChatDeleteMessageAlert(data: $0)
        }
        .anytypeSheet(isPresented: $model.showSendLimitAlert) {
            ChatSendLimitAlert()
        }
        .snackbar(toastBarData: $model.toastBarData)
        .homeBottomPanelHidden(true)
    }
    
    @ViewBuilder
    private var bottomPanel: some View {
        if model.canEdit {
            inputPanel
        }
    }
    
    private var inputPanel: some View {
        VStack(spacing: 0) {
            // For model.sendMessageTaskInProgress disable all view exclude input.
            // If we disable input, the keyboard will hide and show. This causes bugs on the iPad.
            if model.editMessage.isNotNil {
                ChatInputEditView {
                    model.onTapDeleteEdit()
                }
                .disabled(model.sendMessageTaskInProgress)
            } else if let replyToMessage = model.replyToMessage {
                ChatInputReplyView(model: replyToMessage) {
                    model.onTapDeleteReply()
                }
                .disabled(model.sendMessageTaskInProgress)
            }
            ChatInputAttachmentsViewContainer(objects: model.linkedObjects) {
                model.didSelectObject(linkedObject: $0)
            } onTapRemove: {
                model.onTapRemoveLinkedObject(linkedObject: $0)
            }
            .disabled(model.sendMessageTaskInProgress)
            ChatInput(
                text: $model.message,
                editing: $model.inputFocused,
                mention: $model.mentionSearchState,
                hasAdditionalData: model.linkedObjects.isNotEmpty,
                disableSendButton: model.attachmentsDownloading || model.textLimitReached || model.sendMessageTaskInProgress,
                disableAddButton: model.sendMessageTaskInProgress,
                sendButtonIsLoading: model.sendButtonIsLoading,
                createObjectTypes: model.typesForCreateObject,
                conversationType: model.conversationType,
                onTapAddObject: {
                    model.onTapAddObjectToMessage()
                },
                onTapAddMedia: {
                    model.onTapAddMediaToMessage()
                },
                onTapAddFiles: {
                    model.onTapAddFilesToMessage()
                },
                onTapCamera: {
                    model.onTapCamera()
                },
                onTapCreateObject: {
                    model.onTapCreateObject(type: $0)
                },
                onTapSend: {
                    model.onTapSendMessage()
                },
                onTapLinkTo: { range in
                    model.onTapLinkTo(range: range)
                },
                onLinkAdded: { link in
                    model.onLinkAdded(link: link)
                },
                onPasteAttachmentsFromBuffer: { items in
                    model.onPasteAttachmentsFromBuffer(items: items)
                }
            )
            .overlay(alignment: .top) {
                if let messageTextLimit = model.messageTextLimit {
                    TextLimitView(
                        text: messageTextLimit,
                        limitReached: model.textLimitReached
                    )
                    .padding(.top, 8)
                }
            }
        }
        .background(Color.Background.navigationPanel)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .chatActionStateTopProvider(state: $actionState)
        .task(id: model.mentionSearchState) {
            try? await model.updateMentionState()
        }
        .throwingTask(id: model.sendMessageTaskInProgress) {
            try await model.sendMessageTask()
        }
        .onChange(of: model.message) { _ in
            model.messageDidChanged()
        }
    }
    
    private var emptyView: some View {
        ConversationEmptyStateView(
            conversationType: model.conversationType,
            participantPermissions: model.participantPermissions,
            action: {
                model.onTapInviteLink()
            }
        )
    }
    
    private var actionView: some View {
        ChatActionPanelView(model: model.actionModel) {
            model.onTapScrollToBottom()
        } onTapMention: {
            model.onTapMention()
        }
    }
    
    @ViewBuilder
    private var mainView: some View {
        ChatCollectionView(
            items: model.mesageBlocks,
            scrollProxy: model.collectionViewScrollProxy,
            bottomPanel: bottomPanel,
            emptyView: emptyView,
            showEmptyState: model.showEmptyState,
            output: model
        ) { _ in
            ChatMessageUnreadView()
        } headerBuilder: {
            ChatMessageHeaderView(text: $0)
        } actionView: {
            actionView
        } scrollToTop: {
            await model.scrollToTop()
        } scrollToBottom: {
            await model.scrollToBottom()
        } handleVisibleRange: { from, to in
            model.visibleRangeChanged(from: from, to: to)
        } handleBigDistanceToTheBottom: {
            model.bigDistanceToTheBottomChanged(isBig: $0)
        } onTapCollectionBackground: {
            model.onTapDismissKeyboard()
        }
//        .messageFlashId($model.messageHiglightId)
    }
}
