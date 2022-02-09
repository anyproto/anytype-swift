import SwiftUI

struct TextRelationViewSwiftUI: View {
    let text: String?
    let style: RelationStyle
    var allowMultiLine: Bool = false
    let hint: String

    var body: some View {
        if let text = text, text.isNotEmpty {
            AnytypeText(
                text,
                style: style.font,
                color: style.fontColor
            )
                .multilineTextAlignment(.leading)
                .lineLimit(allowMultiLine ? nil : 1)
        } else {
            RelationsListRowPlaceholderView(hint: hint, type: style.placeholderType)
        }
    }
}

struct TextRelationViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        TextRelationViewSwiftUI(
            text: "nil",
            style: .regular(allowMultiLine: false),
            hint: "Hint"
        )
    }
}
