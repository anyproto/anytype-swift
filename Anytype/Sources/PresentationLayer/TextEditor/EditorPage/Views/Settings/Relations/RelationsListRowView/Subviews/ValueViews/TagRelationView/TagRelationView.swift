import SwiftUI

struct TagRelationView: View {
    
    let value: [TagRelation]
    let hint: String
    
    var body: some View {
        if value.isNotEmpty {
            tagsView
            
        } else {
            RelationsListRowHintView(hint: hint)
        }
    }
    
    private var tagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(value) { tag in
                    AnytypeText(tag.text, style: .relation1Regular, color: tag.textColor.asColor)
                        .lineLimit(1)
                        .padding(.horizontal, 5)
                        .background(tag.backgroundColor.asColor)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5.0)
                                .stroke(
                                    tag.backgroundColor == .grayscaleWhite ? AnytypeColor.grayscale30.asColor : tag.backgroundColor.asColor,
                                    lineWidth: 1
                                )
                        )
                        .frame(height: 24)
                }
            }.padding(.horizontal, 1)
        }
    }
}

struct TagRelationView_Previews: PreviewProvider {
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

