import SwiftUI

struct TagPropertyView: View {
    let tags: [Property.Tag.Option]
    let hint: String
    let style: PropertyStyle

    var body: some View {
        if tags.isNotEmpty {
            if maxTags > 0 {
                withMoreTagsView
            } else {
                scrollRelations
            }
        } else {
            PropertyValuePlaceholderView(hint: hint, style: style)
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

    private func contnetView(tags: [Property.Tag.Option]) -> some View {
        ForEach(tags) { tag in
            TagView(
                config: TagView.Config(
                    text: tag.text,
                    textColor: tag.textColor,
                    backgroundColor: tag.backgroundColor,
                    textFont: style.font,
                    guidlines: style.tagViewGuidlines
                )
            )
        }
    }

    private func moreTagsView(count: Int) -> some View {
        Group {
            let leftTagsCount = "+\(count)"

            switch style {
            case .regular, .featuredBlock, .set:
                AnytypeText(leftTagsCount, style: .relation2Regular)
                .foregroundColor(.Text.secondary)
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

private extension TagPropertyView {
    
    private var maxTags: Int {
        switch style {
        case .filter, .setCollection, .kanbanHeader, .regular, .featuredBlock: return 1
        case .set: return 0
        }
    }
    
    private var hSpacing: CGFloat {
        switch style {
        case .regular, .set, .filter: return 8
        case .featuredBlock, .setCollection, .kanbanHeader: return 6
        }
    }
}

struct TagRelationView_Previews: PreviewProvider {
    static var previews: some View {
        TagPropertyView(
            tags: [
                Property.Tag.Option(id: "id1", text: "text1", textColor: Color.Dark.teal, backgroundColor: Color.VeryLight.default),
                Property.Tag.Option(id: "id2", text: "text2", textColor: Color.Dark.red, backgroundColor: Color.VeryLight.red),
                Property.Tag.Option(id: "id3", text: "text3", textColor: Color.Dark.teal, backgroundColor: Color.VeryLight.teal),
                Property.Tag.Option(id: "id4", text: "text4", textColor: Color.Dark.red, backgroundColor: Color.VeryLight.red),
                Property.Tag.Option(id: "id5", text: "text5", textColor: Color.Dark.teal, backgroundColor: Color.VeryLight.teal),
                Property.Tag.Option(id: "id6", text: "text6", textColor: Color.Dark.red, backgroundColor: Color.VeryLight.red),
                Property.Tag.Option(id: "id7", text: "text7", textColor: Color.Dark.teal, backgroundColor: Color.VeryLight.teal),
                Property.Tag.Option(id: "id8", text: "text8", textColor: Color.Dark.red, backgroundColor: Color.VeryLight.red),
                Property.Tag.Option(id: "id9", text: "text9", textColor: Color.Dark.teal, backgroundColor: Color.VeryLight.teal),
                Property.Tag.Option(id: "id10", text: "text10", textColor: Color.Dark.red, backgroundColor: Color.VeryLight.red)
            ],
            hint: "Hint",
            style: .regular(allowMultiLine: false)
        )
    }
}

