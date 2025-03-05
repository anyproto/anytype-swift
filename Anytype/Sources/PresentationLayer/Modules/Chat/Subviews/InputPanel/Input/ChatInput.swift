import SwiftUI
import Services

struct ChatInput: View {
    
    @Binding var text: NSAttributedString
    @Binding var editing: Bool
    @Binding var mention: ChatTextMention
    let hasAdditionalData: Bool
    let disableSendButton: Bool
    let disableAddButton: Bool
    let createObjectTypes: [ObjectType]
    let onTapAddPage: () -> Void
    let onTapAddList: () -> Void
    let onTapAddMedia: () -> Void
    let onTapAddFiles: () -> Void
    let onTapCamera: () -> Void
    let onTapCreateObject: (_ type: ObjectType) -> Void
    let onTapSend: () -> Void
    let onTapLinkTo: (_ range: NSRange) -> Void
    let onLinkAdded: (_ url: URL) -> Void
    
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
            Button { onTapCamera() } label: {
                Label(Loc.Chat.Actions.Menu.camera, systemImage: "camera")
            }
            
            Button { onTapAddMedia() } label: {
                Label(Loc.Chat.Actions.Menu.photos, systemImage: "photo")
            }
            
            Button { onTapAddFiles() } label: {
                Label(Loc.Chat.Actions.Menu.files, systemImage: "doc")
            }
            
            Button { onTapAddPage() } label: {
                Label(Loc.Chat.Actions.Menu.pages, systemImage: "doc.plaintext")
            }
            
            Button { onTapAddList() } label: {
                Label(Loc.Chat.Actions.Menu.lists, systemImage: "list.bullet")
            }
            
            Divider()
            
            Menu {
                ForEach(createObjectTypes) { type in
                    Button {
                        onTapCreateObject(type)
                    } label: {
                        Text(type.displayName)
                    }
                }
            } label: {
                Text(Loc.Chat.Actions.Menu.more)
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
                Text(Loc.Message.Input.emptyPlaceholder)
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
                linkParsed: onLinkAdded
            )
        }
    }
    
    @ViewBuilder
    private var sendButton: some View {
        if hasAdditionalData || !text.string.isEmpty {
            Button {
                onTapSend()
            } label: {
                EnableStateImage(enable: .Chat.SendMessage.active, disable: .Chat.SendMessage.inactive)
            }
            .disabled(disableSendButton)
            .frame(width: 32, height: 56)
        }
    }
}
