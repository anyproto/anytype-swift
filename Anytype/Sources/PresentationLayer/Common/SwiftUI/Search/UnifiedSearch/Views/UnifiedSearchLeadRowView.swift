import SwiftUI
import Services

// Shared row shape for the grouped lead sections (People, Types): icon · title ·
// caption line · trailing drill. Person rows wear the avatar on a member circle
// to tell a person from their 1:1 channel.
struct UnifiedSearchLeadRowView: View {

    let icon: Icon
    let title: String
    let caption: String?
    var badged = false
    let onTap: () -> Void
    let onDrill: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                iconView

                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(title, style: .previewTitle2Medium)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)
                    if let caption {
                        AnytypeText(caption, style: .relation2Regular)
                            .foregroundStyle(Color.Text.secondary)
                            .lineLimit(1)
                    }
                }

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

    @ViewBuilder
    private var iconView: some View {
        if badged {
            IconView(icon: icon)
                .frame(width: 32, height: 32)
                .allowsHitTesting(false)
                .frame(width: 48, height: 48)
                .background(Color.Shape.transparentSecondary)
                .clipShape(.circle)
        } else {
            IconView(icon: icon)
                .frame(width: 48, height: 48)
                .allowsHitTesting(false)
        }
    }
}
