import SwiftUI

final class SettingsAssembly {
    func settingsView() -> some View {
        SettingsView(viewModel: SettingsViewModel(
            authService: ServiceLocator.shared.authService()
        ))
    }
}
