import SwiftUI

struct TextRelationView: View {
    let value: String?
    let hint: String
    let style: RelationStyle
    var allowMultiLine: Bool = false
    
    var body: some View {
        if let value = value, value.isNotEmpty {
            AnytypeText(
                value,
                style: style.font,
                color: style.fontColor
            )
                .lineLimit(allowMultiLine ? nil : 1)
        } else {
            RelationsListRowPlaceholderView(hint: hint, type: style.placeholderType)
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
