import SwiftUI

struct DiscusionInput: View {
    
    @Binding var text: AttributedString
    
    @State private var editing: Bool = false
    let onTapAddObject: () -> Void
    let onTapSend: () -> Void
    
    var body: some View {
        HStack {
            Button {
                onTapAddObject()
            } label: {
                Image(asset: .X32.plus)
            }
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
            Button {
                onTapSend()
            } label: {
                IconView(asset: .X32.moveTo)
            }
            .disabled(text.isEmpty)
            
        }
        .background(Color.Background.primary)
    }
}

#Preview {
    DiscusionInput(text: .constant(AttributedString()), onTapAddObject: {}, onTapSend: {})
}
