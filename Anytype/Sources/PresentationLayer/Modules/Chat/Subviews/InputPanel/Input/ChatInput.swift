import SwiftUI

struct ChatInput: View {
    
    @Binding var text: NSAttributedString
    @Binding var editing: Bool
    @Binding var mention: ChatTextMention
    let hasAdditionalData: Bool
    let disableSendButton: Bool
    let disableAddButton: Bool
    let onTapAddObject: () -> Void
    let onTapAddMedia: () -> Void
    let onTapAddFiles: () -> Void
    let onTapCamera: () -> Void
    let onTapSend: () -> Void
    let onTapLinkTo: (_ range: NSRange) -> Void
    
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
            Button {
                onTapAddObject()
            } label: {
                Text(Loc.Chat.Actions.Menu.objects)
            }
            Button {
                onTapAddMedia()
            } label: {
                Text(Loc.Chat.Actions.Menu.media)
            }
            Button {
                onTapAddFiles()
            } label: {
                Text(Loc.Chat.Actions.Menu.files)
            }
            Button {
                onTapCamera()
            } label: {
                Text(Loc.Chat.Actions.Menu.camera)
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
                    .anytypeStyle(.bodyRegular)
                    .foregroundColor(.Text.tertiary)
                    .padding(.top, 15)
                    .allowsHitTesting(false)
                    .lineLimit(1)
            }
            ChatTextView(text: $text, editing: $editing, mention: $mention, minHeight: 56, maxHeight: 156, linkTo: onTapLinkTo)
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
