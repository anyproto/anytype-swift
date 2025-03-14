import Foundation
import SwiftUI


// Workaround for ios 18
// .preferredColorScheme(nil) do not discard preferences to default -> always darkmode when login from darkmode auth flow
final class AppInterfaceStyle {
    
    private weak var window: UIWindow?
    private(set) var defaultStyle: UIUserInterfaceStyle
    private var defaultStyleOverride: UIUserInterfaceStyle?
    
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    
    init(window: UIWindow?) {
        self.window = window
        self.defaultStyle = Container.shared.userDefaultsStorage().userInterfaceStyle
    }
    
    @MainActor
    func setDefaultStyle(_ style: UIUserInterfaceStyle) {
        defaultStyle = style
        userDefaults.userInterfaceStyle = style
        updateUserInterfaceStyle()
    }
    
    @MainActor
    func overrideDefaultStyle(_ style: UIUserInterfaceStyle?) {
        defaultStyleOverride = style
        updateUserInterfaceStyle()
    }
    
    @MainActor
    private func updateUserInterfaceStyle() {
        if let defaultStyleOverride {
            window?.overrideUserInterfaceStyle = defaultStyleOverride
            return
        }
        
        window?.overrideUserInterfaceStyle = defaultStyle
    }
}


extension EnvironmentValues {
    @Entry var appInterfaceStyle = AppInterfaceStyle(window: nil)
}

extension View {
    func setAppInterfaceStyleEnv(window: UIWindow?) -> some View {
        environment(\.appInterfaceStyle, AppInterfaceStyle(window: window))
    }
}


private struct OverrideDefaultInterfaceStyleModifier: ViewModifier {
    
    let style: UIUserInterfaceStyle?
    
    @Environment(\.appInterfaceStyle)
    private var appInterfaceStyle
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                appInterfaceStyle.overrideDefaultStyle(style)
            }
    }
}

extension View {
    func overrideDefaultInterfaceStyle(_ style: UIUserInterfaceStyle?) -> some View {
        self.modifier(OverrideDefaultInterfaceStyleModifier(style: style))
    }
}
