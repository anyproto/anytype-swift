import Foundation
import SwiftUI

struct LaunchCircle: View {
    
    private enum Constants {
        static let maxSide: CGFloat = 128
        static let middleSide: CGFloat = 48
        static let minSide: CGFloat = 16
    }
    
    @State private var side: CGFloat = Constants.minSide
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [Color.Launch.circle.opacity(opacity), Color.Launch.circle]),
                    center: .center,
                    startRadius: side * 0,
                    endRadius: side * 0.5
                )
            )
            .frame(width: side, height: side)
            .modifier(PulseAnimation(side: $side, middleSide: Constants.middleSide, maxSide: Constants.maxSide))
    }
    
    private var opacity: CGFloat {
        let maxSideOpacity = Constants.middleSide - 1
        let minSideOpacity = Constants.minSide
        let opacity = (maxSideOpacity - side) / (maxSideOpacity - minSideOpacity)
        return max(min(opacity, 1), 0)
    }
}
