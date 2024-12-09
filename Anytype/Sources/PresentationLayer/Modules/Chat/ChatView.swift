import SwiftUI
import PhotosUI

struct ChatView: View {
    
    @StateObject private var model: ChatViewModel
    @State private var actionState: CGFloat = 0
    
    init(spaceId: String, chatId: String, output: (any ChatModuleOutput)?) {
        self._model = StateObject(wrappedValue: ChatViewModel(spaceId: spaceId, chatId: chatId, output: output))
    }
    
    var body: some View {
        ZStack {
            mainView
                .ignoresSafeArea()
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
            await model.subscribeOnPermissions()
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
        .anytypeSheet(item: $model.deleteMessageConfirmation) {
            ChatDeleteMessageAlert(message: $0)
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
    }
    
    private var inputPanel: some View {
        VStack(spacing: 0) {
            if model.editMessage.isNotNil {
                ChatInputEditView {
                    model.onTapDeleteEdit()
                }
            } else if let replyToMessage = model.replyToMessage {
                ChatInputReplyView(model: replyToMessage) {
                    model.onTapDeleteReply()
                }
            }
            MessageInputAttachmentsViewContainer(objects: model.linkedObjects) {
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
        .background(Color.Background.navigationPanel)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .chatActionStateTopProvider(state: $actionState)
        .task(id: model.mentionSearchState) {
            try? await model.updateMentionState()
        }
    }
    
    @ViewBuilder
    private var mainView: some View {
        ChatCollectionView(items: model.mesageBlocks, scrollProxy: model.collectionViewScrollProxy, bottomPanel: bottomPanel) {
            MessageView(data: $0, output: model)
        } headerBuilder: {
            ChatMessageHeaderView(text: $0)
        } scrollToBottom: {
            await model.scrollToBottom()
        }
        .overlay(alignment: .center) {
            if model.showEmptyState {
                ChatEmptyStateView()
            }
        }
    }
}
