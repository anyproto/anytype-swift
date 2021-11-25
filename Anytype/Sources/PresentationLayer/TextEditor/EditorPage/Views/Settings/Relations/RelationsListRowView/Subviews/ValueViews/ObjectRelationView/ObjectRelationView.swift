import SwiftUI

struct ObjectRelationView: View {
    
    let value: [ObjectRelation]
    let hint: String
    
    var body: some View {
        if value.isNotEmpty {
            objectsList
        } else {
            RelationsListRowHintView(hint: hint)
        }
    }
    
    private var objectsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(value) { object in
                    objectView(objectRelation: object)
                }
            }.padding(.horizontal, 1)
        }
    }
    
    private func objectView(objectRelation: ObjectRelation) -> some View {
        HStack(spacing: 6) {
            SwiftUIObjectIconImageView(
                iconImage: objectRelation.icon,
                usecase: .mention(.body)
            )
                .frame(width: 20, height: 20)
            
            AnytypeText(
                objectRelation.text,
                style: .relation1Regular,
                color: .textPrimary
            )
                .lineLimit(1)
        }
    }
    
}

struct ObjectRelationView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectRelationView(value: [], hint: "Hint")
    }
}
