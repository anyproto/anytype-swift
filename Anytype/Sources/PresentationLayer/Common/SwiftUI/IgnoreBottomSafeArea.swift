import Foundation
import SwiftUI

// System .ignoresSafeArea(.keyboard) doesn't work in some cases. For example:
// ZStack {
//     content1 // Should be with safeArea
//     content2 // Should be without safeArea
//         .ignoresSafeArea(.keyboard) // <--- Doesn't work
//         .anytypeIgnoreBottomSafeArea() // <--- Works
// }
private struct IgnoreBottomSafeAreaModifier: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { reader in
            content
                .position(x: reader.size.width * 0.5, y: reader.size.height - reader.safeAreaInsets.bottom)
        }
        .ignoresSafeArea(.keyboard)
    }
}

extension View {
    public func anytypeIgnoreBottomSafeArea() -> some View {
        modifier(IgnoreBottomSafeAreaModifier())
    }
}
