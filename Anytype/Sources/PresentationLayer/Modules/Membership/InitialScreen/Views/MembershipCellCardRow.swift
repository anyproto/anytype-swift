import SwiftUI


// Rounded "Cell Card" entry row: 64pt tall, filled neutral background, label on
// the left and a trailing icon (disclosure chevron or external-link arrow).
struct MembershipCellCardRow: View {
    enum TrailingIcon {
        case disclosure
        case externalLink
    }

    let text: String
    let icon: TrailingIcon
    let onTap: () -> ()

    var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            onTap()
        } label: {
            HStack(spacing: 8) {
                AnytypeText(text, style: .previewTitle1Regular)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                trailingIcon
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.Shape.transparentTertiary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var trailingIcon: some View {
        switch icon {
        case .disclosure:
            IconView(icon: .asset(.RightAttribute.disclosure))
                .frame(width: 24, height: 24)
        case .externalLink:
            IconView(icon: .asset(.X18.webLink))
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        MembershipCellCardRow(text: "Activate Code", icon: .disclosure, onTap: {})
        MembershipCellCardRow(text: "See all plans", icon: .externalLink, onTap: {})
    }
    .padding(16)
}
