import SwiftUI

struct RelationsListRowHintView: View {
    let hint: String
    
    var body: some View {
        AnytypeText(hint, style: .callout, color: .textTertiary)
            .lineLimit(1)
    }
}

struct ObjectRelationRowHintView_Previews: PreviewProvider {
    static var previews: some View {
        RelationsListRowHintView(hint: "hint")
    }
}
