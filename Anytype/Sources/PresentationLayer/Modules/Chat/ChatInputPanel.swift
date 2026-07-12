import SwiftUI
import AnytypeCore

// Extracted from ChatView so a keystroke (a change to `model.message`) re-renders only this
// input subtree — hosted in its own UIHostingController — instead of re-evaluating
// ChatView.body and rebuilding the message-collection representable. (IOS-6508)
struct ChatInputPanel: View {

    @Bindable var model: ChatViewModel
    @Binding var actionState: ChatActionOverlayState

    var body: some View {
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
        .task(id: model.sendMessageTaskInProgress) {
            await model.sendMessageTask()
        }
        .onChange(of: model.message) {
            model.messageDidChanged()
        }
    }
}
