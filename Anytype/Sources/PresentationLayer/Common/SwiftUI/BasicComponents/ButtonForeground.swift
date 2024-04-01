import Foundation
import SwiftUI

private struct ButtonForegroundViewModifier: ViewModifier {
    
    @Environment(\.isEnabled) private var isEnable
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(isEnable ? .Button.active : .Button.inactive)
    }
}

extension View {
    func buttonDynamicForegroundColor() -> some View {
        modifier(ButtonForegroundViewModifier())
    }
}
