import Foundation
import SwiftUI

struct LaunchCircle: View {
    
    @State private var side: CGFloat = 16
    
    private let minSideOpacity: CGFloat = 16
    private let maxSideOpacity: CGFloat = 47
    private let duration: CGFloat = 1.6
    
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
                withAnimation(.easeInOut(duration: duration + duration)) {
                    side = 128
                }
                // TODO: Migrate to completion from iOS 17
                withAnimation(.easeInOut(duration: duration).repeatForever().delay(duration)) {
                    side = 48
                }
            }
    }
    
    private var opacity: CGFloat {
        let opacity = (maxSideOpacity - side) / (maxSideOpacity - minSideOpacity)
        return max(min(opacity, 1), 0)
    }
}
