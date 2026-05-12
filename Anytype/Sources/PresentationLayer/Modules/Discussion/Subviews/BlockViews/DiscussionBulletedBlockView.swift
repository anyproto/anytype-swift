import SwiftUI

struct DiscussionBulletedBlockView: View {

    let content: AttributedString

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("\u{2022}")
                .anytypeStyle(.calloutRegular)
                .foregroundStyle(Color.Control.primary)
                .frame(width: 20, height: 20)
            Text(content)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
