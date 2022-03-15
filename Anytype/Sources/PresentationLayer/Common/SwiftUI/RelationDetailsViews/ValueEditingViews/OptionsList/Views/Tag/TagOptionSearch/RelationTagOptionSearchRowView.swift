import SwiftUI

struct RelationTagOptionSearchRowView: View {
    
    let tag: Relation.Tag.Option
    @Binding var selectedTagIds: [String]
    
    var body: some View {
        content
            .padding(.vertical, 14)
            .divider()
    }
    
    private var content: some View {
        Button {
            if selectedTagIds.contains(tag.id) {
                selectedTagIds.removeAll { $0 == tag.id }
            } else {
                selectedTagIds.append(tag.id)
            }
        } label: {
            HStack(spacing: 0) {
                TagView(
                    viewModel: TagView.Model(
                        text: tag.text,
                        textColor: tag.textColor,
                        backgroundColor: tag.backgroundColor
                    ),
                    guidlines: RelationStyle.regular(allowMultiLine: false).tagViewGuidlines
                )
                Spacer()
                
                if selectedTagIds.contains(tag.id) {
                    Image.optionChecked.foregroundColor(.textSecondary)
                }
            }
            .frame(height: 20)
        }
    }
}

struct RelationTagOptionSearchRowView_Previews: PreviewProvider {
    static var previews: some View {
        RelationTagOptionSearchRowView(
            tag: Relation.Tag.Option(
                id: "id",
                text: "text",
                textColor: UIColor.Text.amber,
                backgroundColor: UIColor.Background.amber,
                scope: .local
            ),
            selectedTagIds: .constant([""]))
    }
}
