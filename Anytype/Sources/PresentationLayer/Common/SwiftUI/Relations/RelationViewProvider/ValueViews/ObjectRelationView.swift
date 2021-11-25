import SwiftUI

struct ObjectRelationView: View {
    let value: [ObjectRelation]
    let hint: String
    let style: RelationStyle
    
    var body: some View {
        if value.isNotEmpty {
            objectsList
        } else {
            RelationsListRowHintView(hint: hint)
        }
    }
    
    private var objectsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: objectRelationStyle.hSpcaingList) {
                ForEach(value) { object in
                    objectView(objectRelation: object)
                }
            }.padding(.horizontal, 1)
        }
    }
    
    private func objectView(objectRelation: ObjectRelation) -> some View {
        HStack(spacing: objectRelationStyle.hSpcaingObject) {
            SwiftUIObjectIconImageView(
                iconImage: objectRelation.icon,
                usecase: .mention(.body)
            )
                .frame(width: objectRelationStyle.size.width, height: objectRelationStyle.size.height)
            
            AnytypeText(
                objectRelation.text,
                style: .relation1Regular,
                color: .textPrimary
            )
                .lineLimit(1)
        }
    }
}

private extension ObjectRelationView {
    struct ObjectRelationStyle {
        let hSpcaingList: CGFloat
        let hSpcaingObject: CGFloat
        let size: CGSize
    }

    var objectRelationStyle: ObjectRelationStyle {
        switch style {
        case .regular:
            return ObjectRelationStyle(hSpcaingList: 8, hSpcaingObject: 6, size: .init(width: 20, height: 20))
        case .featuredRelationBlock:
            return ObjectRelationStyle(hSpcaingList: 6, hSpcaingObject: 4, size: .init(width: 16, height: 16))
        }
    }
}


struct ObjectRelationView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectRelationView(value: [], hint: "Hint", style: .regular(allowMultiLine: false))
    }
}
