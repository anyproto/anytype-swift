import SwiftUI

enum MembershipTierGradient: String {
    case teal
    case blue
    case red
    case purple
    case ice
    
    var color: Color {
        switch self {
        case .teal:
            .Gradients.fadingTeal
        case .blue:
            .Gradients.fadingBlue
        case .red:
            .Gradients.fadingRed
        case .purple:
            .Gradients.fadingPurple
        case .ice:
            .Gradients.fadingIce
        }
    }
}

extension MembershipTierGradient: View {
    var body: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: color, location: 0.0),
                Gradient.Stop(color: .Shape.tertiary, location: 0.3)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    MembershipTierGradient.teal
}
