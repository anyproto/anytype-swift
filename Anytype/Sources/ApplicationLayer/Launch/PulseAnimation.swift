import SwiftUI

struct PulseAnimation: ViewModifier {

    @Binding var side: CGFloat
    
    var middleSide: CGFloat = 48
    var maxSide: CGFloat = 128
    var initialDuration: CGFloat = 3.2
    var duration: CGFloat = 1.6
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                withAnimation(.easeInOut(duration: initialDuration)) {
                    side = maxSide
                }
                // TODO: Migrate to completion from iOS 17
                withAnimation(.easeInOut(duration: duration).repeatForever().delay(initialDuration)) {
                    side = middleSide
                }
            }
    }
}

