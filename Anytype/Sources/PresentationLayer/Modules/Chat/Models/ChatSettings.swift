import Foundation
import SwiftUI

struct ChatSetings {
    let showHeader: Bool
}

struct ChatSettingsKey: EnvironmentKey {
    static let defaultValue = ChatSetings(showHeader: true)
}

extension EnvironmentValues {
    var chatSettings: ChatSetings {
        get { self[ChatSettingsKey.self] }
        set { self[ChatSettingsKey.self] = newValue }
    }
}

struct ChatColorTheme {
    let listBackground: Color
}

extension ChatColorTheme {
    static let editor = ChatColorTheme(
        listBackground: .Background.primary
    )

    static let home = ChatColorTheme(
        listBackground: .clear
    )
}

struct ChatColorThemeKey: EnvironmentKey {
    static let defaultValue = ChatColorTheme(
        // Use any random colors to detect problem with environment
        listBackground: .red
    )
}

extension EnvironmentValues {
    var chatColorTheme: ChatColorTheme {
        get { self[ChatColorThemeKey.self] }
        set { self[ChatColorThemeKey.self] = newValue }
    }
}
