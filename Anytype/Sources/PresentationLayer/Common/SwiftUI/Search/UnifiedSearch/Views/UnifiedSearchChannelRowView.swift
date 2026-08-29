import SwiftUI
import Services

struct UnifiedSearchChannelRow: Identifiable, Hashable {
    let spaceId: String
    let title: String
    let icon: Icon

    var id: String { spaceId }
}

struct UnifiedSearchChannelRowView: View {

    let row: UnifiedSearchChannelRow
    // Primary tap opens the space; the drill affordance scopes the search to it instead
    let onTap: () -> Void
    let onDrill: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                IconView(icon: row.icon)
                    .frame(width: 48, height: 48)
                    .allowsHitTesting(false)

                AnytypeText(row.title, style: .previewTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)

                Spacer()

                Button {
                    onDrill()
                } label: {
                    Image(asset: .X18.search)
                        .foregroundStyle(Color.Control.secondary)
                        .fixTappableArea()
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Loc.search)
            }
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .fixTappableArea()
            .newDivider()
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}
