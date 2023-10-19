import Foundation

final class InitialCoordinatorViewModel: ObservableObject {
    
    private let middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    
    @Published var showWarningAlert: Bool = false
    
    init(
        middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol,
        applicationStateService: ApplicationStateServiceProtocol
    ) {
        self.middlewareConfigurationProvider = middlewareConfigurationProvider
        self.applicationStateService = applicationStateService
    }
    
    func onAppear() {
        #if DEBUG
        Task { @MainActor in
            do {
                let version = try await middlewareConfigurationProvider.libraryVersion()
                if !version.hasPrefix("v") && (UserDefaultsConfig.usersId.isEmpty || UserDefaultsConfig.showUnstableMiddlewareError) {
                    showWarningAlert.toggle()
                    UserDefaultsConfig.showUnstableMiddlewareError = false
                } else {
                    showLoginOrAuth()
                    UserDefaultsConfig.showUnstableMiddlewareError = true
                }
            } catch {
                showLoginOrAuth()
            }
        }
        #else
        showLoginOrAuth()
        #endif
    }
    
    func contunueWithoutLogout() {
        showLoginOrAuth()
    }
    
    func contunueWithLogout() {
        UserDefaultsConfig.usersId = ""
        showLoginOrAuth()
    }
    
    // MARK: - Private
    
    private func showLoginOrAuth() {
        if UserDefaultsConfig.usersId.isNotEmpty {
            applicationStateService.state = .login
        } else {
            applicationStateService.state = .auth
        }
    }
    
}
