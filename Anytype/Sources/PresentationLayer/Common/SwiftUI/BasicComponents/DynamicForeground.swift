import Foundation
import SwiftUI

@available(iOS 17.0, *)
private struct DynamicForegroundStyle: ShapeStyle {
    
    let enabledColor: Color
    let disabledColor: Color
    
    // Resolve method availabe from ios 17. But compiler doesn't show the error
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        if environment.isEnabled {
            return enabledColor
        } else {
            return disabledColor
        }
    }
}

@available(iOS, deprecated: 17.0)
private struct DynamicForegroundStyleiOS16: ViewModifier {
    
    let enabledColor: Color
    let disabledColor: Color
    
    @Environment(\.isEnabled) private var isEnable
    
    func body(content: Content) -> some View {
        if isEnable {
            content.foregroundStyle(enabledColor)
        } else {
            content.foregroundStyle(disabledColor)
        }
    }
}

extension View {
    func buttonDynamicForegroundStyle() -> some View {
        dynamicForegroundStyle(color: .Control.active, disabledColor: .Control.inactive)
    }
    
    func navPanelDynamicForegroundStyle() -> some View {
        dynamicForegroundStyle(color: .Control.transparentActive, disabledColor: .Control.transparentInactive)
    }
    
    func dynamicForegroundStyle(color: Color, disabledColor: Color) -> some View {
        if #available(iOS 17.0, *) {
            return foregroundStyle(DynamicForegroundStyle(enabledColor: color, disabledColor: disabledColor))
        } else {
            return modifier(DynamicForegroundStyleiOS16(enabledColor: color, disabledColor: disabledColor))
        }
    }
}
