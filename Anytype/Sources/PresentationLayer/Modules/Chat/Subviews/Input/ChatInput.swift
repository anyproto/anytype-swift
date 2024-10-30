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
                ChatTextView(text: $text, editing: $editing, mention: $mention, minHeight: 56, maxHeight: 212, linkTo: onTapLinkTo)
                if text.string.isEmpty {
                    Text(Loc.Message.Input.emptyPlaceholder)
                        .anytypeStyle(.bodyRegular)
                        .foregroundColor(.Text.tertiary)
                        .padding(.leading, 6)
                        .padding(.top, 15)
                        .allowsHitTesting(false)
                        .lineLimit(1)
                }
            }
            
            Menu {
                Button {
                    onTapAddFiles()
                } label: {
                    Text(Loc.files)
                }
                Button {
                    onTapAddMedia()
                } label: {
                    Text(Loc.media)
                }
                Button {
                    onTapAddObject()
                } label: {
                    Text(Loc.objects)
                }
            } label: {
                Image(asset: .X32.attachment)
                    .foregroundColor(.Control.navPanelIcon)
            }
            .frame(height: 56)
            
            if hasAdditionalData || !text.string.isEmpty {
                Group {
                    if additionalDataLoading {
                        DotsView()
                            .frame(width: 32, height: 6)
                    } else {
                        Button {
                            onTapSend()
                        } label: {
                            Image(asset: .X32.sendMessage)
                                .foregroundColor(Color.Control.button)
                        }
                    }
                }
                .frame(width: 32, height: 56)
            }
                
        }
        .padding(.horizontal, 8)
        .background(Color.Background.navigationPanel)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .border(16, color: .Shape.transperentSecondary)
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}
