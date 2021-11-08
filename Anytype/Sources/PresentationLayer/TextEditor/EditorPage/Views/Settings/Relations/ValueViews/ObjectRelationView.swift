import SwiftUI

struct ObjectRelationView: View {
    
    let value: ObjectRelation?
    let hint: String
    
    var body: some View {
        if let value = value {
            objectView(objectRelation: value)
        } else {
            AnytypeText(
                hint,
                style: .callout,
                color: .textTertiary
            )
                .lineLimit(1)
        }
    }
    
    private func objectView(objectRelation: ObjectRelation) -> some View {
        HStack(spacing: 3) {
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
        ObjectRelationView(value: nil, hint: "Hint")
    }
}
