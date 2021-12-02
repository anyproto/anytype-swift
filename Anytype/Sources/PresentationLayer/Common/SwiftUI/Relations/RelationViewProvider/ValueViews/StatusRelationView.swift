import SwiftUI

struct StatusRelationView: View {
    let value: RelationValue.Status?
    let hint: String
    let style: RelationStyle
    
    var body: some View {
        if let value = value {
            AnytypeText(value.text, style: style.font, color: value.color.asColor)
                .lineLimit(1)
        } else {
            RelationsListRowPlaceholderView(hint: hint, type: style.placeholderType)
        }
    }
}

struct StatusRelationView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationView(value: RelationValue.Status(id: "", text: "text", color: .pureTeal), hint: "Hint", style: .regular(allowMultiLine: false))
    }
}
