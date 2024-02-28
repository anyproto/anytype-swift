import SwiftUI

struct TextRelationView: View {
    let text: String?
    let style: RelationStyle
    let hint: String

    var body: some View {
        if let text = text, text.isNotEmpty {
            AnytypeText(
                text,
                style: style.font,
                color: style.fontColorWithError
            )
                .multilineTextAlignment(.leading)
                .lineLimit(style.allowMultiLine ? nil : 1)
        } else {
            RelationsListRowPlaceholderView(hint: hint, style: style)
        }
    }
}

struct TextRelationView_Previews: PreviewProvider {
    static var previews: some View {
        TextRelationView(
            text: "nil",
            style: .regular(allowMultiLine: false),
            hint: "Hint"
        )
    }
}
