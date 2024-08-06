import SwiftUI

struct DiscussionView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                message("Message 1")
                message("Message 2")
                message("Message 3")
            }
        }
        .safeAreaInset(edge: .bottom) {
            DiscusionInput()
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
