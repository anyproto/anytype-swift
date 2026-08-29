import SwiftUI
import Services

struct UnifiedSearchTokenViewModel: Identifiable, Hashable {
    let token: UnifiedSearchToken
    let title: String
    let icon: Icon?

    var id: String { token.id }
}

// Search field with filter tokens rendered as pills before the text - the
// platform convention: tap selects a token, backspace removes the
// selected token (or selects the last one first). No close icon on pills.
struct UnifiedSearchBar: View {

    let tokens: [UnifiedSearchTokenViewModel]
    let selectedTokenId: String?
    // While the user types, pills with an icon collapse to the icon alone
    // (a space token collapses to the space icon, a person to the avatar)
    let collapsesToIcons: Bool
    @Binding var text: String
    let onTokenTap: (UnifiedSearchToken) -> Void
    let onRemoveToken: (UnifiedSearchToken) -> Void
    let onBackspaceWhenEmpty: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        barContent
            .padding(.vertical, 9)
            .padding(.horizontal, 12)
            .glassCapsule
    }

    private var barContent: some View {
        HStack(spacing: 8) {
            Image(asset: .X18.search)
                .foregroundStyle(Color.Control.primary)

            ForEach(tokens) { token in
                tokenPill(token)
            }

            UnifiedSearchTextField(
                placeholder: Loc.search,
                text: $text,
                onBackspaceWhenEmpty: onBackspaceWhenEmpty,
                onSubmit: onSubmit
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 60)

            Button {
                text = ""
            } label: {
                Image(asset: .multiplyCircleFill)
                    .renderingMode(.template)
                    .foregroundStyle(Color.Control.primary)
                    .fixTappableArea()
            }
            .buttonStyle(.plain)
            .opacity(text.isEmpty ? 0 : 1)
        }
    }

    private func tokenPill(_ model: UnifiedSearchTokenViewModel) -> some View {
        let isSelected = model.id == selectedTokenId
        let iconOnly = collapsesToIcons && model.icon != nil
        return Button {
            onTokenTap(model.token)
        } label: {
            HStack(spacing: 4) {
                if let icon = model.icon {
                    SearchChipIconView(icon: icon)
                        .frame(width: iconOnly ? 20 : 16, height: iconOnly ? 20 : 16)
                }
                if !iconOnly {
                    AnytypeText(model.title, style: .uxTitle2Medium)
                        .foregroundStyle(isSelected ? Color.Text.white : Color.Text.primary)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, iconOnly ? 4 : 3)
            .padding(.horizontal, iconOnly ? 4 : 10)
            .background(isSelected ? Color.Control.accent100 : Color.Shape.transparentSecondary)
            .clipShape(.capsule)
            .fixTappableArea()
        }
        .buttonStyle(.plain)
        .animation(.default, value: iconOnly)
        .accessibilityLabel(model.title)
        .accessibilityAction(named: Loc.remove) {
            onRemoveToken(model.token)
        }
    }
}

private extension View {
    // Liquid Glass capsule on iOS 26 (like the vault's bottom search field),
    // the previous solid capsule below
    @ViewBuilder
    var glassCapsule: some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: .capsule)
        } else {
            self
                .background(Color.Background.highlightedMedium)
                .clipShape(.capsule)
        }
    }
}
