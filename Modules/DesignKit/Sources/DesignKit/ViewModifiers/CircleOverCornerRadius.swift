import SwiftUI

// Faster than .clipShape(Circle()) for images.
// Much better in chat when there are a lot of icons.
private struct CircleOverCornerRadiusModifier: ViewModifier {
    
    @State private var minSide: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .cornerRadius(minSide)
            .readSize {
                minSide = min($0.width, $0.height)
            }
    }
}

public extension View {
    func circleOverCornerRadius() -> some View {
        modifier(CircleOverCornerRadiusModifier())
    }
}
