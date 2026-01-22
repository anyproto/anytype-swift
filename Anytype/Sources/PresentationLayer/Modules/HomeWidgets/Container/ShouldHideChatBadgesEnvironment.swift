import SwiftUI

private struct ShouldHideChatBadgesKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var shouldHideChatBadges: Bool {
        get { self[ShouldHideChatBadgesKey.self] }
        set { self[ShouldHideChatBadgesKey.self] = newValue }
    }
}

extension View {
    func shouldHideChatBadges(_ value: Bool) -> some View {
        environment(\.shouldHideChatBadges, value)
    }
}
