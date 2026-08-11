import SwiftUI
import PhotosUI
import AnytypeCore

struct ChatView: View {

    @State private var model: ChatViewModel
    @State private var actionState = ChatActionOverlayState()
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    @Environment(\.chatActionProvider) private var chatActionProvider

    private let settingsOutput: (any ObjectSettingsCoordinatorOutput)?

    init(spaceId: String, chatId: String, messageId: String? = nil, useBlocksFormat: Bool = false, output: (any ChatModuleOutput)?, settingsOutput: (any ObjectSettingsCoordinatorOutput)?) {
        self._model = State(wrappedValue: ChatViewModel(spaceId: spaceId, chatId: chatId, messageId: messageId, useBlocksFormat: useBlocksFormat, output: output))
        self.settingsOutput = settingsOutput
    }
    
    var body: some View {
        ZStack {
            HomeWallpaperView(spaceId: model.spaceId)
            mainView
                .ignoresSafeArea()
        }
        .overlay(alignment: .top) {
            ChatHeaderView(
                spaceId: model.spaceId,
                chatId: model.chatId,
                settingsOutput: settingsOutput,
                onTapOpenWidgets: {
                    model.onTapWidgets()
                },
                onTapOpenSpaceSettings: {
                    model.onTapSpaceSettings()
                },
                onTapOpenSearch: {
                    model.onTapOpenSearch()
                }
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
        .fullScreenCover(isPresented: Binding(
            get: { model.searchMode == .fullscreen },
            set: { newValue in
                if !newValue, model.searchMode == .fullscreen {
                    model.onTapCloseSearch()
                }
            }
        )) {
            ChatSearchOverlayView(model: model)
        }
        .snackbar(toastBarData: $model.toastBarData)
        .homeBottomPanelHidden(true)
    }
    
    @ViewBuilder
    private var bottomPanel: some View {
        if model.searchMode == .inline {
            ChatSearchInlineBar(
                text: model.searchQuery,
                onTap: { model.onTapInlineSearchBar() },
                onTapClose: { model.onTapCloseSearch() }
            )
        } else if model.canEdit {
            ChatInputPanel(model: model, actionState: $actionState)
        }
    }
    
    private var emptyView: some View {
        ConversationEmptyStateView(
            isOneToOne: model.isOneToOneSpace,
            participantPermissions: model.participantPermissions,
            addMembersAction: {
                model.onTapInviteLink()
            },
            qrCodeAction: model.qrCodeInviteUrl != nil ? {
                model.onTapShowQrCode()
            } : nil
        )
        .task {
            await model.updateInviteState()
        }
    }
    
    @ViewBuilder
    private var actionView: some View {
        if model.searchMode == .inline {
            ChatSearchNavigationPanel(
                canGoOlder: model.canGoToOlderSearchResult,
                canGoNewer: model.canGoToNewerSearchResult,
                onTapOlder: { model.onTapOlderSearchResult() },
                onTapNewer: { model.onTapNewerSearchResult() }
            )
        } else {
            ChatActionPanelView(model: model.actionModel) {
                model.onTapScrollToBottom()
            } onTapMention: {
                model.onTapMention()
            } onTapReaction: {
                model.onTapReaction()
            }
            .equatable()
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
            showSectionHeaders: true,
            topContentInset: NavigationHeaderConstants.height
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
        .messageYourBackgroundColor(model.messageYourBackgroundColor)
        .messageFlashId($model.messageHiglightId)
    }
    
    @ViewBuilder
    private func cell(data: MessageSectionItem) -> some View {
        switch data {
        case .message(let data):
            MessageView(data: data, output: model)
        case .unread:
            ChatMessageUnreadView()
        case .discussionDivider:
            EmptyView()
        }
    }
}
