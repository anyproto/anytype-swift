import SwiftUI

struct TertiaryPressedBackgroundButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.Shape.transperent : Color.clear)
    }
}
