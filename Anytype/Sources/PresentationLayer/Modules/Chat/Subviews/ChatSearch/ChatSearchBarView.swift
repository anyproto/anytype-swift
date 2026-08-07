import SwiftUI

struct ChatSearchInputBar: View {

    @Binding var text: String
    let onTapClose: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(asset: .X24.search)
                    .foregroundStyle(Color.Text.transparentTertiary)
                // Empty placeholder + custom overlay: AnytypeTextField hardcodes
                // Text.tertiary for placeholders, design wants transparentTertiary
                AutofocusedTextField(placeholder: "", font: .previewTitle1Medium, text: $text)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .overlay(alignment: .leading) {
                        if text.isEmpty {
                            AnytypeText(Loc.Chat.messageSearch, style: .previewTitle1Medium)
                                .foregroundStyle(Color.Text.transparentTertiary)
                                .allowsHitTesting(false)
                        }
                    }
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .glassEffectIOS26(in: Capsule())
            .clipShape(Capsule())

            ChatSearchCloseButton(onTap: onTapClose)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct ChatSearchInlineBar: View {

    let text: String
    let onTap: () -> Void
    let onTapClose: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button {
                onTap()
            } label: {
                HStack(spacing: 8) {
                    Image(asset: .X24.search)
                        .foregroundStyle(Color.Text.transparentTertiary)
                    AnytypeText(text, style: .previewTitle1Medium)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
            }
            .glassEffectInteractiveIOS26(in: Capsule())

            ChatSearchCloseButton(onTap: onTapClose)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

private struct ChatSearchCloseButton: View {

    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            Image(asset: .X24.close)
                .foregroundStyle(Color.Control.primary)
                .frame(width: 48, height: 48)
        }
        .glassEffectInteractiveIOS26(in: Circle())
    }
}
