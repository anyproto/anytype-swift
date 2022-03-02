import SwiftUI

struct TagView: View {
    let tag: Relation.Tag.Option
    let guidlines: Guidlines
    
    var body: some View {
        AnytypeText(tag.text, style: .relation1Regular, color: tag.textColor.suColor)
            .lineLimit(1)
            .padding(.horizontal, guidlines.textPadding)
            .background(tag.backgroundColor.suColor)
            .cornerRadius(guidlines.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: guidlines.cornerRadius)
                    .stroke(
                        tag.backgroundColor == UIColor.TagBackground.default ? Color.strokePrimary : tag.backgroundColor.suColor,
                        lineWidth: 1
                    )
            )
            .frame(height: guidlines.tagHeight)
    }
}

extension TagView {
    
    struct Guidlines {
        let textPadding: CGFloat
        let cornerRadius: CGFloat
        let tagHeight: CGFloat
    }
    
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(
            tag: Relation.Tag.Option(
                id: "id",
                text: "text",
                textColor: UIColor.Background.amber,
                backgroundColor: UIColor.Text.amber,
                scope: .local
            ),
            guidlines: RelationStyle.set.tagViewGuidlines
        )
    }
}
