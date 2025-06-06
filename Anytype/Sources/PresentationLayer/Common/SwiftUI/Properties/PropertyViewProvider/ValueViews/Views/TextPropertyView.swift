import SwiftUI

struct TextPropertyView: View {
    let text: String?
    let style: PropertyStyle
    let hint: String

    var body: some View {
        if let text = text, text.isNotEmpty {
            AnytypeText(
                text,
                style: style.font
            )
                .foregroundColor(style.fontColorWithError)
                .multilineTextAlignment(.leading)
                .lineLimit(style.allowMultiLine ? nil : 1)
        } else {
            PropertyValuePlaceholderView(hint: hint, style: style)
        }
    }
}

#Preview {
    TextPropertyView(
        text: "nil",
        style: .regular(allowMultiLine: false),
        hint: "Hint"
    )
}
