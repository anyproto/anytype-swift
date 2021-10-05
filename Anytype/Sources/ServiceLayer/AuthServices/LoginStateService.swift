import AnytypeCore

final class LoginStateService {
    
    private let seedService: SeedServiceProtocol
    
    init(seedService: SeedServiceProtocol) {
        self.seedService = seedService
    }
    
    func setupStateAfterLoginOrAuth() {
        ObjectTypeProvider.loadObjects()
    }
    
    func cleanStateAfterLogout() {
        try? seedService.removeSeed()
        UserDefaultsConfig.usersIdKey = ""
        MiddlewareConfigurationService.shared.removeCacheConfiguration()
    }
}
