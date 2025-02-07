import SwiftUI
import PhotosUI

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
            ChatHeaderView(spaceId: model.spaceId) {
                model.onTapWidgets()
            }
        }
        .onAppear {
            model.keyboardDismiss = keyboardDismiss
            model.configureProvider(chatActionProvider)
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
            ChatDeleteMessageAlert(message: $0)
        }
        .anytypeSheet(isPresented: $model.showSendLimitAlert) {
            ChatSendLimitAlert()
        }
        .snackbar(toastBarData: $model.toastBarData)
        .homeBottomPanelHidden(true)
    }
    
    private var bottomPanel: some View {
        Group {
            if model.canEdit {
                inputPanel
            } else {
                ChatReadOnlyBottomView()
            }
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
            MessageInputAttachmentsViewContainer(objects: model.linkedObjects) {
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
                createObjectTypes: model.typesForCreateObject,
                onTapAddPage: {
                    model.onTapAddPageToMessage()
                },
                onTapAddList: {
                    model.onTapAddListToMessage()
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
                }
            )
            .overlay(alignment: .top) {
                if let messageTextLimit = model.messageTextLimit {
                    Text(messageTextLimit)
                        .foregroundStyle(model.textLimitReached ? Color.Dark.red : Color.Text.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.Background.secondary)
                        .cornerRadius(12)
                        .border(12, color: .Shape.tertiary)
                        .shadow(color: .black.opacity(0.15), radius: 12)
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
        ChatEmptyStateView()
    }
    
    @ViewBuilder
    private var mainView: some View {
        ChatCollectionView(
            items: model.mesageBlocks,
            scrollProxy: model.collectionViewScrollProxy,
            bottomPanel: bottomPanel,
            emptyView: emptyView,
            showEmptyState: model.showEmptyState
        ) {
            MessageView(data: $0, output: model)
        } headerBuilder: {
            ChatMessageHeaderView(text: $0)
        } scrollToTop: {
            await model.scrollToTop()
        } scrollToBottom: {
            await model.scrollToBottom()
        } handleVisibleRange: { fromId, toId in
            model.visibleRangeChanged(fromId: fromId, toId: toId)
        }
        .messageYourBackgroundColor(model.messageYourBackgroundColor)
    }
}
