import SwiftUI

struct ChatInput: View {
    
    @Binding var text: NSAttributedString
    @Binding var editing: Bool
    @Binding var mention: ChatTextMention
    let hasAdditionalData: Bool
    let additionalDataLoading: Bool
    let onTapAddObject: () -> Void
    let onTapAddMedia: () -> Void
    let onTapAddFiles: () -> Void
    let onTapSend: () -> Void
    let onTapLinkTo: (_ range: NSRange) -> Void
    
    @Environment(\.pageNavigation) private var pageNavigation
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Image(asset: .X32.Island.back)
                .foregroundColor(.Control.navPanelIcon)
                .frame(height: 56)
                .onTapGesture {
                    pageNavigation.pop()
                }
            
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
            } label: {
                Image(asset: .X32.plus)
                    .foregroundColor(.Control.navPanelIcon)
            }
            .frame(height: 56)
            .menuOrder(.fixed)
            
            if hasAdditionalData || !text.string.isEmpty {
                Button {
                    onTapSend()
                } label: {
                    EnableStateImage(enable: .Chat.SendMessage.active, disable: .Chat.SendMessage.inactive)
                }
                .disabled(additionalDataLoading)
                .frame(width: 32, height: 56)
            }
                
        }
        .padding(.horizontal, 8)
    }
}
