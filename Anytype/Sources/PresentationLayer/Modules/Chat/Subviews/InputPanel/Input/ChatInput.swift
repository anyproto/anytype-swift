import SwiftUI
import Services

struct ChatInput: View {

    @Namespace private var glassNamespace

    @Binding var text: NSAttributedString
    @Binding var editing: Bool
    @Binding var mention: ChatTextMention
    let isEditingMessage: Bool
    let linkedObjects: [ChatLinkedObject]
    let disableSendButton: Bool
    let disableAddButton: Bool
    let sendButtonIsLoading: Bool
    let createObjectTypes: [ObjectType]
    let spaceUxType: SpaceUxType
    let onTapAddObject: () -> Void
    let onTapAddMedia: () -> Void
    let onTapAddFiles: () -> Void
    let onTapCamera: () -> Void
    let onTapCreateObject: (_ type: ObjectType) -> Void
    let onTapSend: () -> Void
    let onTapLinkTo: (_ range: NSRange) -> Void
    let onLinkAdded: (_ url: URL) -> Void
    let onPasteAttachmentsFromBuffer: ((_ items: [NSItemProvider]) -> Void)
    let onTapCloseEdit: () -> Void
    let onTapAttachment: (ChatLinkedObject) -> Void
    let onTapRemoveAttachment: (ChatLinkedObject) -> Void
    let replyToMessage: ChatInputReplyModel?
    let onTapCloseReply: () -> Void
    let disableHeaderAndAttachments: Bool
    
    private let mainObjectTypeToCreateKey = ObjectTypeUniqueKey.page

    private var showSendButton: Bool {
        linkedObjects.isNotEmpty || !text.string.isEmpty
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            plusMenu
            inputBubble
            if showSendButton {
                sendButton
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .animation(.easeInOut(duration: 0.2), value: showSendButton)
    }

    private var plusMenu: some View {
        Menu {
            Button { onTapAddMedia() } label: {
                Label(Loc.photos, systemImage: "photo")
            }
            
            Button { onTapCamera() } label: {
                Label(Loc.camera, systemImage: "camera")
            }
            
            Button { onTapAddFiles() } label: {
                Label(Loc.files, systemImage: "doc")
            }
            
            Button { onTapAddObject() } label: {
                Label(Loc.attachObject, systemImage: "link")
            }
            
            if let objectType = mainObjectTypeToCreate() {
                Button {
                    onTapCreateObject(objectType)
                } label: {
                    Label(Loc.newPage, systemImage: "doc.plaintext")
                }
            }
            
            Divider()
            
            Menu {
                ForEach(moreObjectTypesToCreate()) { type in
                    Button {
                        onTapCreateObject(type)
                    } label: {
                        Text(type.displayName)
                    }
                }
            } label: {
                Text(Loc.more)
            }
        } label: {
            Image(asset: .X24.plus)
                .foregroundStyle(Color.Control.primary)
                .padding(4)
        }
        .frame(width: 40, height: 40)
        .contentShape(Circle())
        .glassEffectInteractiveIOS26(in: Circle())
        .menuOrder(.fixed)
        .disabled(disableAddButton)
    }

    private var inputBubble: some View {
        VStack(spacing: 0) {
            if isEditingMessage {
                ChatInputEditView(onTapClose: onTapCloseEdit)
                    .disabled(disableHeaderAndAttachments)
            } else if let replyToMessage {
                ChatInputReplyView(model: replyToMessage, onTapDelete: onTapCloseReply)
                    .disabled(disableHeaderAndAttachments)
            }
            ChatInputAttachmentsViewContainer(
                objects: linkedObjects,
                onTapObject: onTapAttachment,
                onTapRemove: onTapRemoveAttachment
            )
            .disabled(disableHeaderAndAttachments)
            textInputArea
        }
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
        .glassEffectInteractiveIOS26(in: .rect(cornerRadius: 20))
    }

    private var textInputArea: some View {
        ZStack(alignment: .topLeading) {
            if text.string.isEmpty {
                Text(spaceUxType.isStream ? Loc.Message.Input.Stream.emptyPlaceholder : Loc.Message.Input.Chat.emptyPlaceholder)
                    .anytypeStyle(.chatText)
                    .foregroundStyle(Color.Text.tertiary)
                    .padding(.top, 9)
                    .allowsHitTesting(false)
                    .lineLimit(1)
            }
            ChatTextView(
                text: $text,
                editing: $editing,
                mention: $mention,
                minHeight: 40,
                maxHeight: 156,
                linkTo: onTapLinkTo,
                linkParsed: onLinkAdded,
                pasteAttachmentsFromBuffer: onPasteAttachmentsFromBuffer
            )
        }
        .padding(.horizontal, 16)
    }
    
    private var sendButton: some View {
        Button {
            onTapSend()
        } label: {
            if sendButtonIsLoading {
                CircleLoadingView()
                    .frame(width: 24, height: 24)
            } else {
                Image(asset: .Chat.SendMessage.active)
                    .frame(width: 44, height: 44)
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .disabled(disableSendButton)
    }
}

extension ChatInput {
    
    private func mainObjectTypeToCreate() -> ObjectType? {
        createObjectTypes.first { $0.uniqueKey == mainObjectTypeToCreateKey }
    }
    
    private func moreObjectTypesToCreate() -> [ObjectType] {
        createObjectTypes.filter { $0.uniqueKey != mainObjectTypeToCreateKey }
    }
}
