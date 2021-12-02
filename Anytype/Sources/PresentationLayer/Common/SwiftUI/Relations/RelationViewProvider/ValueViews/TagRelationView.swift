import SwiftUI

struct TagRelationView: View {
    let value: [TagRelationValue]
    let hint: String
    let style: RelationStyle

    var body: some View {
        if value.isNotEmpty {
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
                contnetView(value: value)
            }
            .padding(.horizontal, 1)
        }
    }

    private var withMoreTagsView: some View {
        var newValue = value
        if tagStyle.maxTags > 0 {
            newValue = Array(value.prefix(tagStyle.maxTags))
        }

        return HStack(spacing: tagStyle.hSpacing) {
            contnetView(value: newValue)
            moreTagsView
        }
        .padding(.horizontal, 1)
    }

    private func contnetView(value: [TagRelationValue]) -> some View {
        ForEach(value) { tag in
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
        let leftTagsCount = "+\(value.count - tagStyle.maxTags)"

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
            value: [
                TagRelationValue(text: "text", textColor: .darkTeal, backgroundColor: .grayscaleWhite),
                TagRelationValue(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                TagRelationValue(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                TagRelationValue(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                TagRelationValue(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                TagRelationValue(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                TagRelationValue(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                TagRelationValue(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                TagRelationValue(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                TagRelationValue(text: "text2", textColor: .darkRed, backgroundColor: .lightRed)
            ],
            hint: "Hint",
            style: .regular(allowMultiLine: false)
        )
    }
}

