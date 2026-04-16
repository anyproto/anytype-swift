import SwiftUI

struct DiscussionMessageDividerView: View {
    var body: some View {
        VStack(alignment: .center) {
            Rectangle()
                .fill(Color.Shape.secondary)
                .frame(height: 1)
        }
        .frame(height: 20)
    }
}
