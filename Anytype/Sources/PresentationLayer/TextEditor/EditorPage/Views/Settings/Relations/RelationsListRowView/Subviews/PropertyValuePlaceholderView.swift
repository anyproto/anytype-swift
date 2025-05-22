import SwiftUI

struct PropertyValuePlaceholderView: View {
    let hint: String
    let style: PropertyStyle
    
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
            AnytypeText(text, style: style.hintFont)
                .foregroundColor(style.hintColor)
                .lineLimit(1)
        }
    }
}

#Preview {
    PropertyValuePlaceholderView(
        hint: "Relation name",
        style: .regular(allowMultiLine: false)
    )
}
