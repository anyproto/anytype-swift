import AnytypeCore

final class LoginStateService {
    var isFirstLaunchAfterRegistration: Bool = false

    private let seedService: SeedServiceProtocol
    
    init(seedService: SeedServiceProtocol) {
        self.seedService = seedService
    }
    
    func setupStateAfterLoginOrAuth() {
        ObjectTypeProvider.loadObjects()
        MiddlewareConfigurationProvider.shared.removeCachedConfiguration()
    }
    
    func setupStateAfterRegistration() {
        isFirstLaunchAfterRegistration = true
        UserDefaultsConfig.showKeychainAlert = true
        ObjectTypeProvider.loadObjects()
        MiddlewareConfigurationProvider.shared.removeCachedConfiguration()
    }
    
    func cleanStateAfterLogout() {
        UserDefaultsConfig.cleanStateAfterLogout()
        MiddlewareConfigurationProvider.shared.removeCachedConfiguration()
    }
}
