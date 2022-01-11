import SwiftUI

struct TagRelationRowView: View {

    let tag: Relation.Tag.Option
    
    var body: some View {
        HStack(spacing: 0) {
            TagView(tag: tag, guidlines: RelationStyle.regular(allowMultiLine: false).tagViewGuidlines)
            Spacer()
        }
        .frame(height: 20)
        .padding(.vertical, 12)
    }
}

struct TagRelationRowView_Previews: PreviewProvider {
    static var previews: some View {
        TagRelationRowView(
            tag: Relation.Tag.Option(
                id: "id",
                text: "text",
                textColor: UIColor.Text.amber,
                backgroundColor: UIColor.Background.amber,
                scope: .local
            )
        )
    }
}
