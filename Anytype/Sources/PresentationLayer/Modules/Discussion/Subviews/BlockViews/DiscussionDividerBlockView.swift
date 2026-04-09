import SwiftUI

struct DiscussionDividerBlockView: View {

    var body: some View {
        Rectangle()
            .fill(Color.Shape.primary)
            .frame(height: 1)
            .padding(.vertical, 9.5)
    }
}
