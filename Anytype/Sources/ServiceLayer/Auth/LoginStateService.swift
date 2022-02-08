import AnytypeCore

final class LoginStateService {
    var isFirstLaunchAfterRegistration: Bool = false

    private let seedService: SeedServiceProtocol
    
    init(seedService: SeedServiceProtocol) {
        self.seedService = seedService
    }
    
    func setupStateAfterLoginOrAuth() {
        ObjectTypeProvider.loadObjects()
    }
    
    func setupStateAfterRegistration() {
        isFirstLaunchAfterRegistration = true
        UserDefaultsConfig.showKeychainAlert = true
        ObjectTypeProvider.loadObjects()
    }
    
    func cleanStateAfterLogout() {
        UserDefaultsConfig.cleanStateAfterLogout()
        MiddlewareConfigurationService.shared.removeCacheConfiguration()
    }
}
