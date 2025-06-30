import SwiftUI

enum CounterViewStyle {
    case `default`
    case muted
    case highlighted
}

struct CounterView: View {
    
    let count: Int
    let style: CounterViewStyle
    
    init(count: Int, style: CounterViewStyle = .default) {
        self.count = count
        self.style = style
    }
  
    var body: some View {
        Text("\(count)")
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
        case .default: return Color.Control.transparentActive
        case .muted: return Color.Control.inactive
        case .highlighted: return Color.System.amber125
        }
    }
}
