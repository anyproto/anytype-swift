import SwiftUI

struct TextRelationView: View {
    let value: String?
    let hint: String
    let style: RelationStyle
    var allowMultiLine: Bool = false
    
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

    var text: String? {
        if let maxLength = maxLength, let value = value, value.count > maxLength {
            return String(value.prefix(maxLength) + " ...")
        } else {
            return value
        }
    }
}

private extension TextRelationView {
    var maxLength: Int? {
        switch style {
        case .regular, .set: return nil
        case .featuredRelationBlock: return 40
        }
    }
}

struct TextRelationView_Previews: PreviewProvider {
    static var previews: some View {
        TextRelationView(
            value: "nil",
            hint: "Hint",
            style: .regular(allowMultiLine: false)
        )
    }
}
