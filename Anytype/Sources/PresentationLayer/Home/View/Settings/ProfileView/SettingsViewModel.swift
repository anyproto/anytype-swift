import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var loggingOut = false
    @Published var wallpaper = false
    @Published var keychain = false
    @Published var pincode = false
    @Published var about = false
    @Published var debugMenu = false
    
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Logout
    func logout() {
        self.authService.logout() {
            windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
        }
    }
}
