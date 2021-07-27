import AnytypeCore

final class LoginStateService {
    
    private let seedService: SeedServiceProtocol
    
    init(seedService: SeedServiceProtocol) {
        self.seedService = seedService
    }
    
    func setupStateAfterLoginOrAuth() {
        ObjectTypeService.shared.loadObjects()
    }
    
    func cleanStateAfterLogout() {
        try? seedService.removeSeed()
        UserDefaultsConfig.usersIdKey = ""
        MiddlewareConfiguration.shared = nil
        MiddlewareConfigurationService.shared.removeCacheConfiguration()
    }
}
