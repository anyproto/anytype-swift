import SwiftUI

extension EnvironmentValues {
    @Entry var messageYourBackgroundColor: Color = .Background.Chat.bubbleYour
    @Entry var messageReactionSelectedColor: Color = .Background.Chat.bubbleYour
    @Entry var messageReactionUnselectedColor: Color = .Background.Chat.bubbleSomeones
}

extension View {
    func messageYourBackgroundColor(_ color: Color) -> some View {
        environment(\.messageYourBackgroundColor, color)
    }

    func messageReactionSelectedColor(_ color: Color) -> some View {
        environment(\.messageReactionSelectedColor, color)
    }

    func messageReactionUnselectedColor(_ color: Color) -> some View {
        environment(\.messageReactionUnselectedColor, color)
    }
}
