import SwiftUI

struct TagView: View {
    
    let viewModel: Model
    let style: RelationStyle
    
    var body: some View {
        AnytypeText(viewModel.text, style: style.font, color: viewModel.textColor)
            .lineLimit(1)
            .padding(.horizontal, style.tagViewGuidlines.textPadding)
            .background(viewModel.backgroundColor)
            .cornerRadius(style.tagViewGuidlines.cornerRadius)
            .if(viewModel.backgroundColor == Color.VeryLight.default) {
                $0.overlay(
                    RoundedRectangle(cornerRadius: style.tagViewGuidlines.cornerRadius)
                        .stroke(Color.Shape.primary, lineWidth: 1)
                )
            }
            .frame(height: style.tagViewGuidlines.tagHeight)
    }
}

extension TagView {
    
    struct Model {
        let text: String
        let textColor: Color
        let backgroundColor: Color
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
                textColor: Color.VeryLight.amber,
                backgroundColor: Color.Dark.amber
            ),
            style: .set
        )
    }
}
