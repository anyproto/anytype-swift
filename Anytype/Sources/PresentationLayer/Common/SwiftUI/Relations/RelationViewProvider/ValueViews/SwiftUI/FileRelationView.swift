import SwiftUI

struct FileRelationView: View {
    let options: [Relation.File.Option]
    let hint: String
    let style: RelationStyle
    
    var body: some View {
        if options.isNotEmpty {
            objectsList
        } else {
            RelationsListRowPlaceholderView(hint: hint, style: style)
        }
    }
    
    private var objectsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: style.objectRelationStyle.hSpaсingList) {
                ForEach(options) { objectView(option: $0) }
            }
            .padding(.horizontal, 1)
        }
    }
    
    private func objectView(option: Relation.File.Option) -> some View {
        HStack(spacing: style.objectRelationStyle.hSpaсingObject) {
            SwiftUIObjectIconImageView(
                iconImage: option.icon,
                usecase: style.objectIconImageUsecase
            )
            
            AnytypeText(
                option.title,
                style: style.font,
                color: style.fontColor
            )
                .lineLimit(1)
        }
    }
}


struct FileRelationView_Previews: PreviewProvider {
    static var previews: some View {
        FileRelationView(options: [], hint: "Hint", style: .regular(allowMultiLine: false))
    }
}
