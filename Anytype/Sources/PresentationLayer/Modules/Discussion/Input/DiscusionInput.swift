import SwiftUI

struct DiscusionInput: View {
    
    @State private var editing: Bool = false
    
    var body: some View {
        HStack {
            Image(asset: .X32.plus)
                .onTapGesture {
                    editing = false
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
    DiscusionInput()
}
