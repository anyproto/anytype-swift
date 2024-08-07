import SwiftUI

struct DiscusionInput: View {
    
    @Binding var text: AttributedString
    
    @State private var editing: Bool = false
    let onTapAddObject: () -> Void
    let onTapSend: () -> Void
    
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
                DiscussionTextView(text: $text, editing: $editing, minHeight: 56, maxHeight: 212)
                if text.isEmpty {
                    Text(Loc.Message.Input.emptyPlaceholder)
                        .anytypeStyle(.bodyRegular)
                        .foregroundColor(.Text.tertiary)
                        .padding(.leading, 6)
                        .padding(.top, 15)
                        .allowsHitTesting(false)
                        .lineLimit(1)
                }
            }
            
            if !text.isEmpty {
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
    DiscusionInput(text: .constant(AttributedString()), onTapAddObject: {}, onTapSend: {})
}
