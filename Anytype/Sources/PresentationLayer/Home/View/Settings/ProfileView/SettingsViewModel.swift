import SwiftUI
import Amplitude


final class SettingsViewModel: ObservableObject {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Logout
    func logout() {
        self.authService.logout() {
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.accountStop)
            windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
        }
    }
}
