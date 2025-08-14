import SwiftUI

private struct ProportionalPaddingModifier: ViewModifier {
    
    let padding: CGFloat
    let side: CGFloat
    
    @State private var minSide: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding((minSide / side) * padding)
            .readSize {
                minSide = min($0.width, $0.height)
            }
    }
}

public extension View {
    func proportionalPadding(padding: CGFloat, side: CGFloat) -> some View {
        modifier(ProportionalPaddingModifier(padding: padding, side: side))
    }
}
