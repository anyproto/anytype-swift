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
            DiscussionTextView(text: $text, editing: $editing, minHeight: 56, maxHeight: 212)
            Button {
                onTapSend()
            } label: {
                IconView(asset: .X32.moveTo)
            }
            .disabled(text.startIndex == text.endIndex)
            
        }
        .background(Color.Background.primary)
    }
}

#Preview {
    DiscusionInput(text: .constant(AttributedString()), onTapAddObject: {}, onTapSend: {})
}
