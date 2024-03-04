import SwiftUI

struct RelationValuePlaceholderView: View {
    let hint: String
    let style: RelationStyle
    
    var body: some View {
        content
    }
    
    @ViewBuilder
    private var content: some View {
        switch style.placeholderType {
        case .hint:
            hintView(with: hint)
        case let .clear(withHint):
            hintView(with: withHint ? Loc.Relation.View.Hint.empty : nil)
        case .empty:
            Color.Background.primary
        }
    }
    
    @ViewBuilder
    private func hintView(with text: String?) -> some View {
        if let text {
            AnytypeText(text, style: style.hintFont, color: .Text.tertiary)
                .lineLimit(1)
        }
    }
}

#Preview {
    RelationValuePlaceholderView(
        hint: "Relation name",
        style: .regular(allowMultiLine: false)
    )
}
