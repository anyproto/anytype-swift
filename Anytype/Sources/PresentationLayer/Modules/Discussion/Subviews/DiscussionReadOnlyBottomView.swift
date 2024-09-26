import SwiftUI

struct DiscussionReadOnlyBottomView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            IconView(asset: .X18.lock)
                .foregroundStyle(Color.Button.active)
            Text(Loc.Discussion.readOnly)
                .anytypeStyle(.caption1Regular)
                .foregroundStyle(Color.Text.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
