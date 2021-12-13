import SwiftUI

struct TagRelationRowView: View {
    
    let tag: Relation.Tag.Option
    let onTap: () -> ()
    
    var body: some View {
        content
            .padding(.vertical, 14)
            .modifier(DividerModifier(spacing: 0))
    }
    
    private var content: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                TagView(tag: tag, guidlines: RelationStyle.regular(allowMultiLine: false).tagViewGuidlines)
                Spacer()
            }
            .frame(height: 20)
        }
    }
}

struct TagRelationRowView_Previews: PreviewProvider {
    static var previews: some View {
        TagRelationRowView(
            tag: Relation.Tag.Option(
                id: "id",
                text: "text",
                textColor: .darkAmber,
                backgroundColor: .lightAmber,
                scope: .local
            ),
            onTap: {}
        )
    }
}
