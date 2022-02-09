import SwiftUI

struct FileRelationView: View {
    let options: [Relation.File.Option]
    let hint: String
    let style: RelationStyle
    
    var body: some View {
        if options.isNotEmpty {
            objectsList
        } else {
            RelationsListRowPlaceholderView(hint: hint, type: style.placeholderType)
        }
    }
    
    private var objectsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: objectRelationStyle.hSpaсingList) {
                ForEach(options) { objectView(option: $0) }
            }
            .padding(.horizontal, 1)
        }
    }
    
    private func objectView(option: Relation.File.Option) -> some View {
        HStack(spacing: objectRelationStyle.hSpaсingObject) {
            SwiftUIObjectIconImageView(
                iconImage: option.icon,
                usecase: .mention(.body)
            )
                .frame(width: objectRelationStyle.size.width, height: objectRelationStyle.size.height)
            
            AnytypeText(
                option.title,
                style: .relation1Regular,
                color: .textPrimary
            )
                .lineLimit(1)
        }
    }
}

private extension FileRelationView {
    struct ObjectRelationStyle {
        let hSpaсingList: CGFloat
        let hSpaсingObject: CGFloat
        let size: CGSize
    }

    var objectRelationStyle: ObjectRelationStyle {
        switch style {
        case .regular, .set:
            return ObjectRelationStyle(hSpaсingList: 8, hSpaсingObject: 6, size: .init(width: 20, height: 20))
        case .featuredRelationBlock:
            return ObjectRelationStyle(hSpaсingList: 6, hSpaсingObject: 4, size: .init(width: 16, height: 16))
        }
    }
}


struct FileRelationView_Previews: PreviewProvider {
    static var previews: some View {
        FileRelationView(options: [], hint: "Hint", style: .regular(allowMultiLine: false))
    }
}
