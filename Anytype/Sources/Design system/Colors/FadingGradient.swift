import SwiftUI

enum FadingGradient: String {
    case green
    case yellow
    case pink
    case purple
    
    var color: Color {
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

extension FadingGradient: View {
    var body: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: color, location: 0.0),
                Gradient.Stop(color: .Shape.tertiary, location: 0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    FadingGradient.green
}
