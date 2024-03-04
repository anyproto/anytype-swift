import SwiftUI

enum BannerFadingGradient: String {
    case green
    case yellow
    case pink
    case purple
    
    var color: Color {
        switch self {
        case .green:
            .Gradients.fadingGreen
        case .yellow:
            .Gradients.fadingYellow
        case .pink:
            .Gradients.fadingPink
        case .purple:
            .Gradients.fadingPurple
        }
    }
}

extension BannerFadingGradient: View {
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
    BannerFadingGradient.green
}
