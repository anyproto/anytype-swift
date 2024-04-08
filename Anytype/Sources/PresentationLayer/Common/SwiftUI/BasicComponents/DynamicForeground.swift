import Foundation
import SwiftUI

private struct DynamicForegroundViewModifier: ViewModifier {
    
    @Environment(\.isEnabled) private var isEnable
    let enabledColor: Color
    let disabledColor: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(isEnable ? enabledColor : disabledColor)
    }
}

extension View {
    func buttonDynamicForegroundColor() -> some View {
        modifier(DynamicForegroundViewModifier(enabledColor: .Button.active, disabledColor: .Button.inactive))
    }
    
    func textDynamicForegroundColor(color: Color) -> some View {
        modifier(DynamicForegroundViewModifier(enabledColor: color, disabledColor: .Text.tertiary))
    }
}
