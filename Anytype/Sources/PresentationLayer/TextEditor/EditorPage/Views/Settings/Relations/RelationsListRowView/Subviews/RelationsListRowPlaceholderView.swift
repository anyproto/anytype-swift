import SwiftUI

struct RelationsListRowPlaceholderView: View {
    let hint: String
    let type: RelationPlaceholderType
    
    var body: some View {
        Group {
            switch type {
            case .hint:
                RelationsListRowHintView(hint: hint)
            case .empty:
                EmptyView()
            }
        }
    }
}

struct RelationsListRowPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        RelationsListRowHintView(hint: "hint")
    }
}
