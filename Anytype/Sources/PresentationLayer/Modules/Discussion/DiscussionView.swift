import SwiftUI

struct DiscussionView: View {
    
    @State var editing = false
    
    var body: some View {
        ScrollView {
            VStack {
                message("Message 1")
                message("Message 2")
                message("Message 3")
            }
        }
        .safeAreaInset(edge: .bottom) {
            DiscusionInput(editing: $editing)
        }
    }
    
    private func message(_ text: String) -> some View {
        Text(text)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background(Color.gray)
            .cornerRadius(8)
    }
}

#Preview {
    DiscussionView()
}
