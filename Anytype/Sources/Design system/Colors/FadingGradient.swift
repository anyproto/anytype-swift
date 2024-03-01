import SwiftUI


enum FadingGradient: String, CaseIterable, Identifiable {
    case green
    case yellow
    case pink
    case purple
    
    var id: String { rawValue }
    
    // do not make var - SwiftUI glitches
    func gradientView() -> some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: color, location: 0.0),
                Gradient.Stop(color: .Shape.tertiary, location: 0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var color: Color {
        switch self {
        case .green:
            Color(hex: "#CFF6CF")
        case .yellow:
            Color(hex: "#FEF2C6")
        case .pink:
            Color(hex: "#FFEBEB")
        case .purple:
            Color(hex: "#EBEDFE")
        }
    }
    
}

#Preview {
    FadingGradient.green.gradientView()
}
