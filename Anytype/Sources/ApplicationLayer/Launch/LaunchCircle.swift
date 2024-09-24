import Foundation
import SwiftUI

struct LaunchCircle: View {
    
    private enum Constants {
        static let maxSide: CGFloat = 128
        static let middleSide: CGFloat = 48
        static let minSide: CGFloat = 16
        static let duration: CGFloat = 1.6
        static let initialDuration: CGFloat = Constants.duration + Constants.duration
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
            .onAppear {
                withAnimation(.easeInOut(duration: Constants.initialDuration)) {
                    side = Constants.maxSide
                }
                // TODO: Migrate to completion from iOS 17
                withAnimation(.easeInOut(duration: Constants.duration).repeatForever().delay(Constants.initialDuration)) {
                    side = Constants.middleSide
                }
            }
    }
    
    private var opacity: CGFloat {
        let maxSideOpacity = Constants.maxSide - 1
        let minSideOpacity = Constants.minSide
        let opacity = (maxSideOpacity - side) / (maxSideOpacity - minSideOpacity)
        return max(min(opacity, 1), 0)
    }
}
