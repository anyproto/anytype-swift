import SwiftUI

struct TagView: View {
    
    let viewModel: Model
    let style: RelationStyle
    
    var body: some View {
        AnytypeText(viewModel.text, style: style.font, color: viewModel.textColor.suColor)
            .lineLimit(1)
            .padding(.horizontal, style.tagViewGuidlines.textPadding)
            .background(viewModel.backgroundColor.suColor)
            .cornerRadius(style.tagViewGuidlines.cornerRadius)
            .if(viewModel.backgroundColor == UIColor.TagBackground.default) {
                $0.overlay(
                    RoundedRectangle(cornerRadius: style.tagViewGuidlines.cornerRadius)
                        .stroke(Color.strokePrimary, lineWidth: 1)
                )
            }
            .frame(height: style.tagViewGuidlines.tagHeight)
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
            style: .set
        )
    }
}
