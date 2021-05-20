import SwiftUI

final class SettingsViewModel: ObservableObject {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Logout
    func logout() {
        self.authService.logout() {
            InMemoryStoreFacade.clearStorage()
            windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
        }
    }
}
