import SwiftUI

struct TagView: View {
    let tag: Relation.Tag.Option
    let guidlines: Guidlines
    
    var body: some View {
        AnytypeText(tag.text, style: .relation2Regular, color: tag.textColor.asColor)
            .lineLimit(1)
            .padding(.horizontal, guidlines.textPadding)
            .background(tag.backgroundColor.asColor)
            .cornerRadius(guidlines.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: guidlines.cornerRadius)
                    .stroke(
                        tag.backgroundColor == .grayscaleWhite ? AnytypeColor.grayscale30.asColor : tag.backgroundColor.asColor,
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
                textColor: .lightAmber,
                backgroundColor: .darkAmber,
                scope: .local
            ),
            guidlines: RelationStyle.set.tagViewGuidlines
        )
    }
}
