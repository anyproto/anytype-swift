import SwiftUI

struct TagRelationRowView: View {

    enum Style {
        case `default`
        case search
    }
    
    let tag: Relation.Tag.Option
    let style: Style = .default
    let onTap: () -> ()
    
    var body: some View {
        content
            .if(style == .default) {
                $0.padding(.vertical, 12)
            }
            .if(style == .search) {
                $0.padding(.vertical, 14)
                    .modifier(DividerModifier(spacing: 0))
            }
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
        .buttonStyle(PlainButtonStyle())
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
