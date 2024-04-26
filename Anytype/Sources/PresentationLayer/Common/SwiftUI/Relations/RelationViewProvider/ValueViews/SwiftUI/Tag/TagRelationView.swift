import SwiftUI

struct TagRelationView: View {
    let tags: [Relation.Tag.Option]
    let hint: String
    let style: RelationStyle

    var body: some View {
        if tags.isNotEmpty {
            if maxTags > 0 {
                withMoreTagsView
            } else {
                scrollRelations
            }
        } else {
            RelationsListRowPlaceholderView(hint: hint, style: style)
        }
    }

    private var scrollRelations: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: hSpacing) {
                contnetView(tags: tags)
            }
            .padding(.horizontal, 1)
        }
    }

    private var withMoreTagsView: some View {
        let leftTagsCount = (tags.count - maxTags) > 0 ? tags.count - maxTags : 0

        return HStack(spacing: hSpacing) {
            contnetView(tags: Array(tags.prefix(maxTags)))

            if leftTagsCount > 0 {
                moreTagsView(count: leftTagsCount)
            }
        }
        .padding(.horizontal, 1)
    }

    private func contnetView(tags: [Relation.Tag.Option]) -> some View {
        ForEach(tags) { tag in
            TagView(
                viewModel: TagView.Model(
                    text: tag.text,
                    textColor: tag.textColor,
                    backgroundColor: tag.backgroundColor
                ),
                style: style
            )
        }
    }

    private func moreTagsView(count: Int) -> some View {
        Group {
            let leftTagsCount = "+\(count)"

            switch style {
            case .regular, .featuredRelationBlock, .set:
                AnytypeText(leftTagsCount, style: .relation2Regular, color: .Text.secondary)
                    .lineLimit(1)
                    .frame(width: 24, height: 18)
                    .background(Color.Shape.tertiary)
                    .cornerRadius(3)
            case .filter, .setCollection, .kanbanHeader:
                CountTagView(count: count, style: style)
            }
        }
    }
}

private extension TagRelationView {
    
    private var maxTags: Int {
        switch style {
        case .regular, .set: return 0
        case .featuredRelationBlock: return 3
        case .filter, .setCollection, .kanbanHeader: return 1
        }
    }
    
    private var hSpacing: CGFloat {
        switch style {
        case .regular, .set, .filter: return 8
        case .featuredRelationBlock, .setCollection, .kanbanHeader: return 6
        }
    }
}

struct TagRelationView_Previews: PreviewProvider {
    static var previews: some View {
        TagRelationView(
            tags: [
                Relation.Tag.Option(id: "id1", text: "text1", textColor: UIColor.Dark.teal, backgroundColor: UIColor.VeryLight.default),
                Relation.Tag.Option(id: "id2", text: "text2", textColor: UIColor.Dark.red, backgroundColor: UIColor.VeryLight.red),
                Relation.Tag.Option(id: "id3", text: "text3", textColor: UIColor.Dark.teal, backgroundColor: UIColor.VeryLight.teal),
                Relation.Tag.Option(id: "id4", text: "text4", textColor: UIColor.Dark.red, backgroundColor: UIColor.VeryLight.red),
                Relation.Tag.Option(id: "id5", text: "text5", textColor: UIColor.Dark.teal, backgroundColor: UIColor.VeryLight.teal),
                Relation.Tag.Option(id: "id6", text: "text6", textColor: UIColor.Dark.red, backgroundColor: UIColor.VeryLight.red),
                Relation.Tag.Option(id: "id7", text: "text7", textColor: UIColor.Dark.teal, backgroundColor: UIColor.VeryLight.teal),
                Relation.Tag.Option(id: "id8", text: "text8", textColor: UIColor.Dark.red, backgroundColor: UIColor.VeryLight.red),
                Relation.Tag.Option(id: "id9", text: "text9", textColor: UIColor.Dark.teal, backgroundColor: UIColor.VeryLight.teal),
                Relation.Tag.Option(id: "id10", text: "text10", textColor: UIColor.Dark.red, backgroundColor: UIColor.VeryLight.red)
            ],
            hint: "Hint",
            style: .regular(allowMultiLine: false)
        )
    }
}

