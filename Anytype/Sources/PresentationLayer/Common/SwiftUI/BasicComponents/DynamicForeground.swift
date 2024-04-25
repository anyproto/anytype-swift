import Foundation
import SwiftUI

private struct DynamicForegroundStyle: ShapeStyle {
    
    let enabledColor: Color
    let disabledColor: Color
    
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        if environment.isEnabled {
            return enabledColor
        } else {
            return disabledColor
        }
    }
}

extension View {
    func buttonDynamicForegroundStyle() -> some View {
        foregroundStyle(DynamicForegroundStyle(enabledColor: .Button.active, disabledColor: .Button.inactive))
    }
    
    func dynamicForegroundStyle(color: Color, disabledColor: Color) -> some View {
        foregroundStyle(DynamicForegroundStyle(enabledColor: color, disabledColor: disabledColor))
    }
}
