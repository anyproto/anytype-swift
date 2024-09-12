import SwiftUI

struct DiscussionView: View {
    
    @StateObject private var model: DiscussionViewModel
    
    init(objectId: String, spaceId: String, chatId: String, output: (any DiscussionModuleOutput)?) {
        self._model = StateObject(wrappedValue: DiscussionViewModel(objectId: objectId, spaceId: spaceId, chatId: chatId, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            DiscussionSpacingContainer {
                mainView
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        if model.canEdit {
                            inputPanel
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
    }
    
    private var inputPanel: some View {
        VStack(spacing: 0) {
            MessageLinkInputViewContainer(objects: model.linkedObjects) {
                model.onTapRemoveLinkedObject(details: $0)
            }
            DiscusionInput(text: $model.message, editing: $model.inputFocused, hasAdditionalData: model.linkedObjects.isNotEmpty) {
                model.onTapAddObjectToMessage()
            } onTapSend: {
                model.onTapSendMessage()
            }
        }
        .overlay(alignment: .top) {
            AnytypeDivider()
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
        if model.showContentEmptyState {
            DiscussionEmptyStateView(objectId: model.objectId) {
                model.didTapIcon()
            } onDone: {
                model.inputFocused = true
            }
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
