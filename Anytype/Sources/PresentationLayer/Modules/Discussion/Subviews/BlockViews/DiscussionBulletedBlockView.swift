import SwiftUI

struct DiscussionBulletedBlockView: View {

    let content: AttributedString

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("\u{2022}")
                .foregroundStyle(Color.Text.secondary)
                .frame(width: 20, height: 20)
            Text(content)
        }
    }
}
