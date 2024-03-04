import SwiftUI

enum MembershipTeirGradient: String {
    case teal
    case blue
    case red
    
    var color: Color {
        switch self {
        case .teal:
            .Gradients.fadingTeal
        case .blue:
            .Gradients.fadingBlue
        case .red:
            .Gradients.fadingRed
        }
    }
}

extension MembershipTeirGradient: View {
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
    MembershipTeirGradient.teal
}
