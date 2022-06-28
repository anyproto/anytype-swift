import SwiftUI

struct RelationsListRowPlaceholderView: View {
    let hint: String
    let style: RelationStyle
    
    var body: some View {
        Group {
            switch style.placeholderType {
            case .hint:
                RelationsListRowHintView(hint: hint, style: style)
            case .empty:
                Color.backgroundPrimary
            case .emptyHint:
                RelationsListRowHintView(hint: Loc.Relation.View.Hint.empty, style: style)
            }
        }
    }
}

struct RelationsListRowPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        RelationsListRowHintView(hint: "hint", style: .set)
    }
}
