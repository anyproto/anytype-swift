import SwiftUI

struct DiscussionMessageDividerView: View {
    var body: some View {
        Rectangle()
            .fill(Color.Shape.secondary)
            .frame(height: 1)
            .padding(.vertical, 12)
    }
}
