import SwiftUI

struct FlowTagRelationView: View {
    /// max count of tags. 0 unlimited, showed as horizontal scroll.
    var maxTags: Int = 0
    let value: [TagRelation]
    let hint: String

    var body: some View {
        if value.isNotEmpty {
            contnetView
        } else {
            ObjectRelationRowHintView(hint: hint)
        }
    }

    private var contnetView: some View {
        var newValue = value
        if maxTags > 0 {
            newValue = Array(value.prefix(maxTags))
        }

        return HStack(spacing: 6) {
            ForEach(newValue) { tag in
                AnytypeText(tag.text, style: .relation2Regular, color: tag.textColor.asColor)
                    .lineLimit(1)
                    .padding(.horizontal, 4)
                    .background(tag.backgroundColor.asColor)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4.0)
                            .stroke(
                                tag.backgroundColor == .grayscaleWhite ? AnytypeColor.grayscale30.asColor : tag.backgroundColor.asColor,
                                lineWidth: 1
                            )
                    )
                    .frame(height: 19)
            }
            leftTagsView
        }.padding(.horizontal, 1)
    }

    private var leftTagsView: some View {
        let leftTagsCount = "+\(value.count - maxTags)"

        return AnytypeText(leftTagsCount, style: .relation2Regular, color: .textSecondary)
            .lineLimit(1)
            .frame(width: 24, height: 19)
            .background(Color.grayscale10)
            .cornerRadius(3)
    }
}

struct FlowTagRelationView_Previews: PreviewProvider {
    static var previews: some View {
        TagRelationView(
            value: [
                TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .grayscaleWhite),
                TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed)
            ],
            hint: "Hint"
        )
    }
}
