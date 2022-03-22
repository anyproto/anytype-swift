import SwiftUI

struct TagRelationRowView: View {

    let viewModel: TagView.Model
    
    var body: some View {
        HStack(spacing: 0) {
            TagView(viewModel: viewModel, guidlines: RelationStyle.regular(allowMultiLine: false).tagViewGuidlines)
            Spacer()
        }
        .frame(height: 48)
    }
}

struct TagRelationRowView_Previews: PreviewProvider {
    static var previews: some View {
        TagRelationRowView(
            viewModel: TagView.Model(
                text: "text",
                textColor: UIColor.Text.amber,
                backgroundColor: UIColor.Background.amber
            )
        )
    }
}
