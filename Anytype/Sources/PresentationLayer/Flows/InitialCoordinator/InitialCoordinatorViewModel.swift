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
                let isUnstableVersion = !version.hasPrefix("v")
                if isUnstableVersion {
                    if (UserDefaultsConfig.usersId.isEmpty || UserDefaultsConfig.showUnstableMiddlewareError) {
                        showWarningAlert.toggle()
                    } else {
                        showLoginOrAuth()
                    }
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
        UserDefaultsConfig.showUnstableMiddlewareError = false
    }
    
    func contunueWithLogout() {
        UserDefaultsConfig.usersId = ""
        showLoginOrAuth()
        UserDefaultsConfig.showUnstableMiddlewareError = false
    }
    
    func contunueWithTrust() {
        showLoginOrAuth()
        UserDefaultsConfig.showUnstableMiddlewareError = false
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
