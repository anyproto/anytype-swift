import SwiftUI

struct FlowTextRelationView: View {
    
    let value: String?
    let hint: String
    
    var body: some View {
        if let value = value, value.isNotEmpty {
            AnytypeText(
                value,
                style: .relation2Regular,
                color: .textSecondary
            )
                .truncationMode(.tail)
                .lineLimit(1)
                .frame(maxWidth: 160)
        } else {
            ObjectRelationRowHintView(hint: hint)
        }
    }
}

struct FlowTextRelationView_Previews: PreviewProvider {
    static var previews: some View {
        TextRelationView(
            value: "nil",
            hint: "Hint"
        )
    }
}
