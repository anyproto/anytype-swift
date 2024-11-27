import Foundation
import SwiftUI

private struct DragIndicatorModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            DragIndicator()
            content
        }
    }
}


extension View {
    func applyDragIndicator() -> some View {
        modifier(DragIndicatorModifier())
    }
}
