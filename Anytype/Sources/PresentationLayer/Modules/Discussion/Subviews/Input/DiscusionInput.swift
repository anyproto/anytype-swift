import SwiftUI

struct DiscusionInput: View {
    
    @Binding var text: NSAttributedString
    @Binding var editing: Bool
    @Binding var mention: DiscussionTextMention
    let hasAdditionalData: Bool
    let onTapAddObject: () -> Void
    let onTapSend: () -> Void
    let onTapLinkTo: (_ range: NSRange) -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Button {
                onTapAddObject()
            } label: {
                Image(asset: .X32.plus)
                    .foregroundColor(Color.Button.active)
            }
            .frame(height: 56)
            ZStack(alignment: .topLeading) {
                DiscussionTextView(text: $text, editing: $editing, mention: $mention, minHeight: 56, maxHeight: 212, linkTo: onTapLinkTo)
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
            
            if hasAdditionalData || !text.string.isEmpty {
                Button {
                    onTapSend()
                } label: {
                    Image(asset: .X32.sendMessage)
                        .foregroundColor(Color.Button.button)
                }
                .frame(height: 56)
            }
        }
        .padding(.horizontal, 8)
        .background(Color.Background.primary)
    }
}

#Preview {
    DiscusionInput(text: .constant(NSAttributedString()), editing: .constant(false), mention: .constant(.finish), hasAdditionalData: true, onTapAddObject: {}, onTapSend: {}, onTapLinkTo: { _ in })
}
