import SwiftUI

final class SettingsAssembly {
    func settingsView() -> some View {
        SettingsView(model: SettingsViewModel(
            authService: ServiceLocator.shared.authService()
        ))
    }
}
