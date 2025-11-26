import Foundation
import SwiftUI

private struct GlobalEnvModifier: ViewModifier {
    
    @State private var windowHolder = WindowHolder(window: nil)
    @State private var model = GlobalEnvModifierModel()
    
    func body(content: Content) -> some View {
        content
            .readWindowHolder($windowHolder)
            .setKeyboardDismissEnv(window: windowHolder.window)
            .setPresentedDismissEnv(window: windowHolder.window)
            .setAppInterfaceStyleEnv(window: windowHolder.window)
            // Legacy :(
            .onChange(of: windowHolder) { _, newValue in
                model.setSceneWindow(newValue.window)
                newValue.window?.overrideUserInterfaceStyle = model.userInterfaceStyle
            }
            
    }
}

@MainActor
@Observable
private final class GlobalEnvModifierModel {
    @Injected(\.userDefaultsStorage) @ObservationIgnored
    private var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.legacyViewControllerProvider) @ObservationIgnored
    private var viewControllerProvider: any ViewControllerProviderProtocol
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        userDefaults.userInterfaceStyle
    }
    
    func setSceneWindow(_ window: UIWindow?) {
        viewControllerProvider.setSceneWindow(window)
    }
}

extension View {
    func setupGlobalEnv() -> some View {
        self.modifier(GlobalEnvModifier())
    }
}
