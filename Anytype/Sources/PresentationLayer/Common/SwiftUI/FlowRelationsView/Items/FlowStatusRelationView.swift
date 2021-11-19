import SwiftUI

struct FlowStatusRelationView: View {
    
    let value: StatusRelation?
    let hint: String
    
    var body: some View {
        if let value = value {
            AnytypeText(value.text, style: .relation2Regular, color: value.color.asColor)
                .lineLimit(1)
        } else {
            ObjectRelationRowHintView(hint: hint)
        }
    }
}

struct FlowStatusRelationView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationView(value: StatusRelation(text: "text", color: .pureTeal), hint: "Hint")
    }
}
