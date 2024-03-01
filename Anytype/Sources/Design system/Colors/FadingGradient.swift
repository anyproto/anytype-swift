import SwiftUI

enum FadingGradient: String {
    case green
    case yellow
    case pink
    case purple
    
    var color: Color {
        switch self {
        case .green:
            .Gradients.Fading.green
        case .yellow:
            .Gradients.Fading.yellow
        case .pink:
            .Gradients.Fading.pink
        case .purple:
            .Gradients.Fading.purple
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
