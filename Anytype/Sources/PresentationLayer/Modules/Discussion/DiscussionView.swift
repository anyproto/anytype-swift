import SwiftUI
import PhotosUI

struct DiscussionView: View {
    
    @StateObject private var model: DiscussionViewModel
    @State private var actionState: CGFloat = 0
    
    init(objectId: String, spaceId: String, chatId: String, output: (any DiscussionModuleOutput)?) {
        self._model = StateObject(wrappedValue: DiscussionViewModel(objectId: objectId, spaceId: spaceId, chatId: chatId, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            DiscussionSpacingContainer {
                mainView
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        bottomPanel
                    }
            }
            .discussionActionOverlay(state: $actionState) {
                if model.mentionObjects.isNotEmpty {
                    DiscussionMentionList(mentions: model.mentionObjects) {
                        model.didSelectMention($0)
                    }
                }
            }
        }
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
        .photosPicker(isPresented: $model.showPhotosPicker, selection: $model.photosItems)
        .task(id: model.showPhotosPicker) {
            await model.updatePickerItems()
        }
    }
    
    private var bottomPanel: some View {
        Group {
            if model.canEdit {
                inputPanel
            } else {
                DiscussionReadOnlyBottomView()
            }
        }
        .overlay(alignment: .top) {
            AnytypeDivider()
        }
    }
    
    private var inputPanel: some View {
        VStack(spacing: 0) {
            MessageLinkInputViewContainer(objects: model.linkedObjects) {
                model.didSelectObject(linkedObject: $0)
            } onTapRemove: {
                model.onTapRemoveLinkedObject(linkedObject: $0)
            }
            DiscusionInput(
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
        .discussionActionStateTopProvider(state: $actionState)
        .task(id: model.mentionSearchState) {
            try? await model.updateMentionState()
        }
    }
    
    private var headerView: some View {
        DiscussionHeader(
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
            DiscussionEmptyStateView(objectId: model.objectId) {
                model.didTapIcon()
            } onDone: {
                model.inputFocused = true
            }
            .allowsHitTesting(model.canEdit)
        } else {
            DiscussionCollectionView(items: model.mesageBlocks, diffApply: model.messagesScrollUpdate) {
                MessageView(data: $0, output: model)
            } scrollToBottom: {
                await model.scrollToBottom()
            }
        }
    }
}

#Preview {
    DiscussionView(objectId: "", spaceId: "", chatId: "", output: nil)
}
