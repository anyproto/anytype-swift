import SwiftUI

struct TertiaryPressedBackgroundButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.Stroke.transperent : Color.clear)
    }
}
