import SwiftUI

struct RelationsListRowHintView: View {
    let hint: String
    let style: RelationStyle
    
    var body: some View {
        AnytypeText(hint, style: style.hintFont, color: .textTertiary)
            .lineLimit(1)
    }
}

struct ObjectRelationRowHintView_Previews: PreviewProvider {
    static var previews: some View {
        RelationsListRowHintView(hint: "hint", style: .set)
    }
}
