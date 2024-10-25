import SwiftUI
import PhotosUI

struct ChatView: View {
    
    @StateObject private var model: ChatViewModel
    @State private var actionState: CGFloat = 0
    @Environment(\.chatSettings) private var settings
    @Environment(\.chatColorTheme) private var colors
    
    init(objectId: String, spaceId: String, chatId: String, output: (any ChatModuleOutput)?) {
        self._model = StateObject(wrappedValue: ChatViewModel(objectId: objectId, spaceId: spaceId, chatId: chatId, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if settings.showHeader {
                headerView
            }
            mainView
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    bottomPanel
                }
            .chatActionOverlay(state: $actionState) {
                if model.mentionObjects.isNotEmpty {
                    ChatMentionList(mentions: model.mentionObjects) {
                        model.didSelectMention($0)
                    }
                }
            }
        }
        .background(colors.listBackground)
        .task {
            await model.subscribeOnPermissions()
        }
        .task {
            await model.subscribeOnDetails()
        }
        .task {
            await model.subscribeOnSyncStatus()
        }
        .task {
            await model.subscribeOnParticipants()
        }
        .throwingTask {
            try await model.subscribeOnMessages()
        }
        .task(id: model.photosItemsTask) {
            await model.updatePickerItems()
        }
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
        .overlay(alignment: .top) {
            AnytypeDivider()
        }
    }
    
    private var inputPanel: some View {
        VStack(spacing: 0) {
            if let replyToMessage = model.replyToMessage {
                ChatInputReplyView(model: replyToMessage) {
                    model.onTapDeleteReply()
                }
            }
            MessageLinkInputViewContainer(objects: model.linkedObjects) {
                model.didSelectObject(linkedObject: $0)
            } onTapRemove: {
                model.onTapRemoveLinkedObject(linkedObject: $0)
            }
            ChatInput(
                text: $model.message,
                editing: $model.inputFocused,
                mention: $model.mentionSearchState,
                hasAdditionalData: model.linkedObjects.isNotEmpty,
                additionalDataLoading: model.attachmentsDownloading
            ) {
                model.onTapAddObjectToMessage()
            } onTapAddMedia: {
                model.onTapAddMediaToMessage()
            } onTapAddFiles: {
                model.onTapAddFilesToMessage()
            } onTapSend: {
                model.onTapSendMessage()
            } onTapLinkTo: { range in
                model.onTapLinkTo(range: range)
            }
        }
        .chatActionStateTopProvider(state: $actionState)
        .task(id: model.mentionSearchState) {
            try? await model.updateMentionState()
        }
    }
    
    private var headerView: some View {
        ChatHeader(
            syncStatusData: model.syncStatusData,
            icon: model.showTitleData ? model.objectIcon : nil,
            title: model.showTitleData ? model.title : "",
            onSyncStatusTap: { model.onSyncStatusTap() },
            onSettingsTap: { model.onSettingsTap() }
        )
    }
    
    @ViewBuilder
    private var mainView: some View {
        if model.showEmptyState {
            ChatEmptyStateView(objectId: model.objectId, spaceId: model.spaceId) {
                model.didTapIcon()
            } onDone: {
                model.inputFocused = true
            }
            .allowsHitTesting(model.canEdit)
        } else {
            ChatCollectionView(items: model.mesageBlocks, scrollProxy: model.collectionViewScrollProxy) {
                MessageView(data: $0, output: model)
            } scrollToBottom: {
                await model.scrollToBottom()
            }
        }
    }
}

#Preview {
    ChatView(objectId: "", spaceId: "", chatId: "", output: nil)
}
