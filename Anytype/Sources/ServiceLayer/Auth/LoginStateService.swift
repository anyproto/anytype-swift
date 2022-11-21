import AnytypeCore

final class LoginStateService {
    var isFirstLaunchAfterRegistration: Bool = false

    private let seedService: SeedServiceProtocol
    
    init(seedService: SeedServiceProtocol) {
        self.seedService = seedService
    }
    
    func setupStateAfterLoginOrAuth(account: AccountData) {
        MiddlewareConfigurationProvider.shared.setupConfiguration(account: account)
        startSubscriptions()
    }
    
    func setupStateAfterRegistration(account: AccountData) {
        isFirstLaunchAfterRegistration = true
        UserDefaultsConfig.showKeychainAlert = true
        MiddlewareConfigurationProvider.shared.setupConfiguration(account: account)
        startSubscriptions()
    }
    
    func cleanStateAfterLogout() {
        UserDefaultsConfig.cleanStateAfterLogout()
        MiddlewareConfigurationProvider.shared.removeCachedConfiguration()
        stopSubscriptions()
    }
    
    // MARK: - Private
    
    private func startSubscriptions() {
        ServiceLocator.shared.relationDetailsStorage().startSubscription()
        ObjectTypeProvider.shared.startSubscription()
    }
    
    private func stopSubscriptions() {
        ServiceLocator.shared.relationDetailsStorage().stopSubscription()
        ObjectTypeProvider.shared.stopSubscription()
    }
}
