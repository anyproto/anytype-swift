import SwiftUI

struct TagView: View {
    
    let viewModel: Model
    let guidlines: Guidlines
    
    var body: some View {
        AnytypeText(viewModel.text, style: .relation1Regular, color: viewModel.textColor.suColor)
            .lineLimit(1)
            .padding(.horizontal, guidlines.textPadding)
            .background(viewModel.backgroundColor.suColor)
            .cornerRadius(guidlines.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: guidlines.cornerRadius)
                    .stroke(
                        viewModel.backgroundColor == UIColor.TagBackground.default ? Color.strokePrimary : viewModel.backgroundColor.suColor,
                        lineWidth: 1
                    )
            )
            .frame(height: guidlines.tagHeight)
    }
}

extension TagView {
    
    struct Model {
        let text: String
        let textColor: UIColor
        let backgroundColor: UIColor
    }
    
    struct Guidlines: Hashable {
        let textPadding: CGFloat
        let cornerRadius: CGFloat
        let tagHeight: CGFloat
    }
    
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(
            viewModel: TagView.Model(
                text: "text",
                textColor: UIColor.Background.amber,
                backgroundColor: UIColor.Text.amber
            ),
            guidlines: RelationStyle.set.tagViewGuidlines
        )
    }
}
