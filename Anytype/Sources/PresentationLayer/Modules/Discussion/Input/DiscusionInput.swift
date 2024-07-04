import SwiftUI

struct DiscusionInput: View {
    
    @State private var editing: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(asset: .X32.plus)
                    .onTapGesture {
                        editing = false
                    }
                DiscussionTextView(editing: $editing)
            }
            .frame(height: 56)
            if editing {
                HStack {
                    Text("Bottom action panel")
                    Spacer()
                }
                .frame(height: 48)
            } else {
                AnytypeNavigationSpacer()
            }
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
