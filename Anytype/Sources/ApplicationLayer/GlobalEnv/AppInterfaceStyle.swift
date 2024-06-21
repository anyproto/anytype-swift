import Foundation
import SwiftUI

struct AppInterfaceStyle {
    
    private weak var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func callAsFunction(_ style: UIUserInterfaceStyle) {
        window?.overrideUserInterfaceStyle = style
    }
}

struct AppInterfaceStyleKey: EnvironmentKey {
    static let defaultValue = AppInterfaceStyle(window: nil)
}

extension EnvironmentValues {
    var appInterfaceStyle: AppInterfaceStyle {
        get { self[AppInterfaceStyleKey.self] }
        set { self[AppInterfaceStyleKey.self] = newValue }
    }
}

extension View {
    func setAppInterfaceStyleEnv(window: UIWindow?) -> some View {
        environment(\.appInterfaceStyle, AppInterfaceStyle(window: window))
    }
}
