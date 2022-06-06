import AnytypeCore

final class LoginStateService {
    var isFirstLaunchAfterRegistration: Bool = false

    private let seedService: SeedServiceProtocol
    
    init(seedService: SeedServiceProtocol) {
        self.seedService = seedService
    }
    
    func setupStateAfterLoginOrAuth(account: AccountData) {
        MiddlewareConfigurationProvider.shared.setupConfiguration(account: account)
    }
    
    func setupStateAfterRegistration(account: AccountData) {
        isFirstLaunchAfterRegistration = true
        UserDefaultsConfig.showKeychainAlert = true
        MiddlewareConfigurationProvider.shared.setupConfiguration(account: account)
    }
    
    func cleanStateAfterLogout() {
        UserDefaultsConfig.cleanStateAfterLogout()
        MiddlewareConfigurationProvider.shared.removeCachedConfiguration()
    }
}
