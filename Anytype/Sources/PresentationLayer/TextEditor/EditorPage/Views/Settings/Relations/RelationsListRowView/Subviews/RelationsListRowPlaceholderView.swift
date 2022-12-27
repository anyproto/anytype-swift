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
                Color.Background.primary
            case let .clear(withHint):
                if withHint {
                    RelationsListRowHintView(hint: Loc.Relation.View.Hint.empty, style: style)
                } else {
                    EmptyView()
                }
            }
        }
    }
}

struct RelationsListRowPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        RelationsListRowHintView(hint: "hint", style: .set)
    }
}
