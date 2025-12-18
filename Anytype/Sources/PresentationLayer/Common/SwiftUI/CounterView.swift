import SwiftUI

enum CounterViewStyle {
    case `default`
    case muted
    case highlighted
}

struct CounterView: View {

    let text: String
    let style: CounterViewStyle

    init(count: Int, style: CounterViewStyle = .default) {
        self.text = count > 999 ? "999+" : "\(count)"
        self.style = style
    }

    var body: some View {
        Text(text)
            .anytypeFontStyle(.caption1Regular) // Without line height multiple
            .foregroundStyle(Color.Control.white)
            .frame(height: 20)
            .padding(.horizontal, 6)
            .frame(minWidth: 20)
            .background(
                Capsule()
                    .fill(fillColor)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule()) // From iOS 17: Delete clip and use .fill for material
            )
    }
    
    private var fillColor: Color {
        switch style {
        case .default: return Color.Control.transparentSecondary
        case .muted: return Color.Control.transparentTertiary
        case .highlighted: return Color.Control.accent100
        }
    }
}
