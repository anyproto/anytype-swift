import Foundation
import SwiftUI

struct AuthCircle: View {
    
    let minSide: CGFloat
    let maxSide: CGFloat
    
    @State private var side: CGFloat
    
    init(minSide: CGFloat = 128 - 16, maxSide: CGFloat = 128 + 16) {
        self.minSide = minSide
        self.maxSide = maxSide
        self.side = minSide
    }
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [Color.clear, Color.launchColorsCircle]),
                    center: .center,
                    startRadius: side * 0,
                    endRadius: side * 0.5
                )
            )
            .frame(width: side, height: side)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.6).repeatForever()) {
                    side = maxSide
                }
            }
    }
}
