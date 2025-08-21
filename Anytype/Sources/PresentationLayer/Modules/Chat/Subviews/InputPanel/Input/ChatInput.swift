import SwiftUI
import Services

struct ChatInput: View {
    
    @Binding var text: NSAttributedString
    @Binding var editing: Bool
    @Binding var mention: ChatTextMention
    let hasAdditionalData: Bool
    let disableSendButton: Bool
    let disableAddButton: Bool
    let sendButtonIsLoading: Bool
    let createObjectTypes: [ObjectType]
    let conversationType: ConversationType
    let onTapAddObject: () -> Void
    let onTapAddMedia: () -> Void
    let onTapAddFiles: () -> Void
    let onTapCamera: () -> Void
    let onTapCreateObject: (_ type: ObjectType) -> Void
    let onTapSend: () -> Void
    let onTapLinkTo: (_ range: NSRange) -> Void
    let onLinkAdded: (_ url: URL) -> Void
    let onPasteAttachmentsFromBuffer: ((_ items: [NSItemProvider]) -> Void)
    
    private let mainObjectTypeToCreateKey = ObjectTypeUniqueKey.page
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            plusButton
            input
            sendButton
        }
        .padding(.horizontal, 8)
    }
    
    private var plusButton: some View {
        Menu {
            Button { onTapAddMedia() } label: {
                Label(Loc.photos, systemImage: "photo")
            }
            
            if let objectType = mainObjectTypeToCreate() {
                Button {
                    onTapCreateObject(objectType)
                } label: {
                    Label(Loc.newPage, systemImage: "doc.plaintext")
                }
            }
            
            Button { onTapAddObject() } label: {
                Label(Loc.attachObject, systemImage: "link")
            }
            
            Divider()
            
            Menu {
                Button { onTapCamera() } label: {
                    Label(Loc.camera, systemImage: "camera")
                }
                
                Button { onTapAddFiles() } label: {
                    Label(Loc.files, systemImage: "doc")
                }
                
                Divider()
                
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
            Image(asset: .X32.plus)
                .navPanelDynamicForegroundStyle()
        }
        .frame(height: 56)
        .menuOrder(.fixed)
        .disabled(disableAddButton)
    }
    
    private var input: some View {
        ZStack(alignment: .topLeading) {
            if text.string.isEmpty {
                Text(conversationType.isChat ? Loc.Message.Input.Chat.emptyPlaceholder : Loc.Message.Input.Stream.emptyPlaceholder)
                    .anytypeStyle(.chatText)
                    .foregroundColor(.Text.tertiary)
                    .padding(.top, 18)
                    .allowsHitTesting(false)
                    .lineLimit(1)
            }
            ChatTextView(
                text: $text,
                editing: $editing,
                mention: $mention,
                minHeight: 56,
                maxHeight: 156,
                linkTo: onTapLinkTo,
                linkParsed: onLinkAdded,
                pasteAttachmentsFromBuffer: onPasteAttachmentsFromBuffer
            )
        }
    }
    
    @ViewBuilder
    private var sendButton: some View {
        Button {
            onTapSend()
        } label: {
            if sendButtonIsLoading {
                CircleLoadingView()
                    .frame(width: 32, height: 32)
            } else {
                Image(asset: .Chat.SendMessage.active)
            }
        }
        .buttonStyle(StandardPlainButtonStyle())
        .disabled(disableSendButton)
        .frame(width: 32, height: 56)
        // Store in layout for calculate correct textview height when user paste in empty textview
        .opacity(hasAdditionalData || !text.string.isEmpty ? 1 : 0)
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
