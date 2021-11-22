import SwiftUI

struct FlowObjectRelationView: View {
    
    let value: [ObjectRelation]
    let hint: String
    
    var body: some View {
        if value.isNotEmpty {
            objectsList
        } else {
            ObjectRelationRowHintView(hint: hint)
        }
    }
    
    private var objectsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(value) { object in
                    objectView(objectRelation: object)
                }
            }.padding(.horizontal, 1)
        }
    }
    
    private func objectView(objectRelation: ObjectRelation) -> some View {
        HStack(spacing: 4) {
            SwiftUIObjectIconImageView(
                iconImage: objectRelation.icon,
                usecase: .mention(.body)
            )
                .frame(width: 16, height: 16)
            
            AnytypeText(
                objectRelation.text,
                style: .relation2Regular,
                color: .textSecondary
            )
                .lineLimit(1)
        }
    }
    
}

struct FlowObjectRelationView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectRelationView(value: [], hint: "Hint")
    }
}
