import SwiftUI
import PhotosUI
import AnytypeCore

struct DiscussionView: View {

    @State private var model: DiscussionViewModel
    @State private var actionState = ChatActionOverlayState()
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    @Environment(\.chatActionProvider) private var chatActionProvider

    private let settingsOutput: (any ObjectSettingsCoordinatorOutput)?

    init(spaceId: String, objectId: String, objectName: String, discussionId: String?, messageId: String? = nil, output: (any DiscussionModuleOutput)?, settingsOutput: (any ObjectSettingsCoordinatorOutput)?) {
        self._model = State(wrappedValue: DiscussionViewModel(spaceId: spaceId, objectId: objectId, objectName: objectName, chatId: discussionId, messageId: messageId, output: output))
        self.settingsOutput = settingsOutput
    }

    var body: some View {
        ZStack {
            Color.Background.primary
            mainView
                .ignoresSafeArea()
        }
        .messageReactionSelectedColor(Color.Control.accent100)
        .messageReactionUnselectedColor(Color.Shape.transparentSecondary)
        .overlay(alignment: .top) {
            DiscussionHeaderView(
                objectName: model.objectName,
                commentsCount: model.commentsCount,
                chatId: model.chatId,
                spaceId: model.spaceId,
                settingsOutput: settingsOutput
            )
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
            ChatDeleteMessageAlert(message: $0)
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
            ChatInput(
                text: $model.message,
                editing: $model.inputFocused,
                mention: $model.mentionSearchState,
                isEditingMessage: model.editMessage.isNotNil,
                linkedObjects: model.linkedObjects,
                disableSendButton: model.attachmentsDownloading || model.textLimitReached || model.sendMessageTaskInProgress,
                disableAddButton: model.sendMessageTaskInProgress,
                sendButtonIsLoading: model.sendButtonIsLoading,
                createObjectTypes: model.typesForCreateObject,
                spaceUxType: model.spaceUxType,
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
                },
                onTapCloseEdit: {
                    model.onTapDeleteEdit()
                },
                onTapAttachment: {
                    model.didSelectObject(linkedObject: $0)
                },
                onTapRemoveAttachment: {
                    model.onTapRemoveLinkedObject(linkedObject: $0)
                },
                replyToMessage: model.editMessage.isNil ? model.replyToMessage : nil,
                onTapCloseReply: {
                    model.onTapDeleteReply()
                },
                disableHeaderAndAttachments: model.sendMessageTaskInProgress
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
        .padding(.bottom, 8)
        .chatActionStateTopProvider(state: $actionState)
        .task(id: model.mentionSearchState) {
            try? await model.updateMentionState()
        }
        .throwingTask(id: model.sendMessageTaskInProgress) {
            try await model.sendMessageTask()
        }
        .onChange(of: model.message) {
            model.messageDidChanged()
        }
    }

    private var emptyView: some View {
        Spacer()
    }

    private var actionView: some View {
        // Discussions only use scroll-to-bottom; mention/reaction buttons are Chat-only
        ChatActionPanelView(model: model.actionModel) {
            model.onTapScrollToBottom()
        } onTapMention: {
            anytypeAssertionFailure("Mentions scroll is not supported in discussions")
        } onTapReaction: {
            anytypeAssertionFailure("Reactions scroll is not supported in discussions")
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
            showSectionHeaders: false
        ) {
            cell(data: $0)
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
        .messageFlashId($model.messageHiglightId)
    }

    @ViewBuilder
    private func cell(data: MessageSectionItem) -> some View {
        switch data {
        case .message(let data):
            DiscussionMessageView(data: data, output: model)
        case .unread:
            EmptyView()
        case .discussionDivider:
            DiscussionMessageDividerView()
        }
    }
}
