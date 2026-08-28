import SwiftUI
import Services

struct UnifiedSearchTokenViewModel: Identifiable, Hashable {
    let token: UnifiedSearchToken
    let title: String
    let icon: Icon?

    var id: String { token.id }
}

// Search field with filter tokens rendered as removable pills before the text -
// the platform convention (UISearchTextField): tokens cluster left, free text trails.
struct UnifiedSearchBar: View {

    let tokens: [UnifiedSearchTokenViewModel]
    @Binding var text: String
    let onRemoveToken: (UnifiedSearchToken) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(asset: .X18.search)
                .foregroundStyle(Color.Control.secondary)

            ForEach(tokens) { token in
                tokenPill(token)
            }

            AutofocusedTextField(placeholder: Loc.search, font: .uxBodyRegular, text: $text)
                .disableAutocorrection(true)
                .autocapitalization(.none)

            Button {
                text = ""
            } label: {
                Image(asset: .multiplyCircleFill)
                    .renderingMode(.template)
                    .foregroundStyle(Color.Control.secondary)
                    .fixTappableArea()
            }
            .buttonStyle(.plain)
            .opacity(text.isEmpty ? 0 : 1)
        }
        .padding(8)
        .background(Color.Background.highlightedMedium)
        .clipShape(.rect(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func tokenPill(_ model: UnifiedSearchTokenViewModel) -> some View {
        Button {
            onRemoveToken(model.token)
        } label: {
            HStack(spacing: 4) {
                if let icon = model.icon {
                    IconView(icon: icon)
                        .frame(width: 16, height: 16)
                }
                AnytypeText(model.title, style: .uxTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                Image(asset: .multiplyCircleFill)
                    .renderingMode(.template)
                    .foregroundStyle(Color.Control.secondary)
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(Color.Shape.transparentSecondary)
            .clipShape(.capsule)
            .fixTappableArea()
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 160, alignment: .leading)
        .accessibilityLabel(model.title)
        .accessibilityHint(Loc.remove)
    }
}
