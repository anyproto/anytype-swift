import SwiftUI

struct TagRelationView: View {
    let tags: [Relation.Tag.Option]
    let hint: String
    let style: RelationStyle

    var body: some View {
        if tags.isNotEmpty {
            if tagStyle.maxTags > 0 {
                withMoreTagsView
            } else {
                scrollRelations
            }
        } else {
            RelationsListRowPlaceholderView(hint: hint, type: style.placeholderType)
        }
    }

    private var scrollRelations: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: tagStyle.hSpacing) {
                contnetView(tags: tags)
            }
            .padding(.horizontal, 1)
        }
    }

    private var withMoreTagsView: some View {
        var newTags = tags
        if tagStyle.maxTags > 0 {
            newTags = Array(tags.prefix(tagStyle.maxTags))
        }

        return HStack(spacing: tagStyle.hSpacing) {
            contnetView(tags: newTags)
            moreTagsView
        }
        .padding(.horizontal, 1)
    }

    private func contnetView(tags: [Relation.Tag.Option]) -> some View {
        ForEach(tags) { tag in
            AnytypeText(tag.text, style: .relation2Regular, color: tag.textColor.asColor)
                .lineLimit(1)
                .padding(.horizontal, tagStyle.textPadding)
                .background(tag.backgroundColor.asColor)
                .cornerRadius(tagStyle.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: tagStyle.cornerRadius)
                        .stroke(
                            tag.backgroundColor == .grayscaleWhite ? AnytypeColor.grayscale30.asColor : tag.backgroundColor.asColor,
                            lineWidth: 1
                        )
                )
                .frame(height: tagStyle.tagHeight)
        }
    }

    private var moreTagsView: some View {
        let leftTagsCount = "+\(tags.count - tagStyle.maxTags)"

        return AnytypeText(leftTagsCount, style: .relation2Regular, color: .textSecondary)
            .lineLimit(1)
            .frame(width: 24, height: 19)
            .background(Color.grayscale10)
            .cornerRadius(3)
    }
}

private extension TagRelationView {
    struct TagRelationViewStyle {
        let hSpacing: CGFloat
        let textPadding: CGFloat
        let cornerRadius: CGFloat
        let tagHeight: CGFloat
        var maxTags: Int = 0
    }

    private var tagStyle: TagRelationViewStyle {
        switch style {
        case .regular, .set:
            return TagRelationViewStyle(hSpacing: 8, textPadding: 6, cornerRadius: 5, tagHeight: 24)
        case .featuredRelationBlock:
            return TagRelationViewStyle(hSpacing: 6, textPadding: 6, cornerRadius: 4, tagHeight: 19, maxTags: 3)
        }
    }
}

struct TagRelationView_Previews: PreviewProvider {
    static var previews: some View {
        TagRelationView(
            tags: [
                Relation.Tag.Option(id: "id1", text: "text1", textColor: .darkTeal, backgroundColor: .grayscaleWhite, scope: .local),
                Relation.Tag.Option(id: "id2", text: "text2", textColor: .darkRed, backgroundColor: .lightRed, scope: .local),
                Relation.Tag.Option(id: "id3", text: "text3", textColor: .darkTeal, backgroundColor: .lightTeal, scope: .local),
                Relation.Tag.Option(id: "id4", text: "text4", textColor: .darkRed, backgroundColor: .lightRed, scope: .local),
                Relation.Tag.Option(id: "id5", text: "text5", textColor: .darkTeal, backgroundColor: .lightTeal, scope: .local),
                Relation.Tag.Option(id: "id6", text: "text6", textColor: .darkRed, backgroundColor: .lightRed, scope: .local),
                Relation.Tag.Option(id: "id7", text: "text7", textColor: .darkTeal, backgroundColor: .lightTeal, scope: .local),
                Relation.Tag.Option(id: "id8", text: "text8", textColor: .darkRed, backgroundColor: .lightRed, scope: .local),
                Relation.Tag.Option(id: "id9", text: "text9", textColor: .darkTeal, backgroundColor: .lightTeal, scope: .local),
                Relation.Tag.Option(id: "id10", text: "text10", textColor: .darkRed, backgroundColor: .lightRed, scope: .local)
            ],
            hint: "Hint",
            style: .regular(allowMultiLine: false)
        )
    }
}

