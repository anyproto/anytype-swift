import SwiftUI

struct DiscusionInput: View {
    
    @State private var editing: Bool = false
    let onTapAddObject: () -> Void
    
    var body: some View {
        HStack {
            Button {
                onTapAddObject()
            } label: {
                Image(asset: .X32.plus)
            }
            DiscussionTextView(editing: $editing, minHeight: 56, maxHeight: 212)
        }
        .overlay(alignment: .top) {
            AnytypeDivider()
        }
        .background(Color.Background.primary)
    }
}

#Preview {
    DiscusionInput(onTapAddObject: {})
}
