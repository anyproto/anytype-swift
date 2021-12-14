import SwiftUI

struct StatusRelationView: View {
    let statusOption: Relation.Status.Option?
    let hint: String
    let style: RelationStyle
    
    var body: some View {
        if let statusOption = statusOption {
            AnytypeText(statusOption.text, style: style.font, color: statusOption.color.asColor)
                .lineLimit(1)
        } else {
            RelationsListRowPlaceholderView(hint: hint, type: style.placeholderType)
        }
    }
}

struct StatusRelationView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationView(
            statusOption: Relation.Status.Option(
                id: "id",
                text: "text",
                color: AnytypeColor.darkAmber,
                scope: .local
            ),
            hint: "hint",
            style: .regular(allowMultiLine: false)
        )
    }
}
