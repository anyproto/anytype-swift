import AnytypeCore

final class LoginStateService {
    var isFirstLaunchAfterRegistration: Bool = false

    private let seedService: SeedServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol
    private let blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol
    
    init(
        seedService: SeedServiceProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol,
        blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol
    ) {
        self.seedService = seedService
        self.objectTypeProvider = objectTypeProvider
        self.middlewareConfigurationProvider = middlewareConfigurationProvider
        self.blockWidgetExpandedService = blockWidgetExpandedService
    }
    
    func setupStateAfterLoginOrAuth(account: AccountData) {
        middlewareConfigurationProvider.setupConfiguration(account: account)
        startSubscriptions()
    }
    
    func setupStateAfterRegistration(account: AccountData) {
        isFirstLaunchAfterRegistration = true
        UserDefaultsConfig.showKeychainAlert = true
        middlewareConfigurationProvider.setupConfiguration(account: account)
        startSubscriptions()
    }
    
    func cleanStateAfterLogout() {
        UserDefaultsConfig.cleanStateAfterLogout()
        blockWidgetExpandedService.clearData()
        middlewareConfigurationProvider.removeCachedConfiguration()
        stopSubscriptions()
    }
    
    // MARK: - Private
    
    private func startSubscriptions() {
        ServiceLocator.shared.relationDetailsStorage().startSubscription()
        objectTypeProvider.startSubscription()
    }
    
    private func stopSubscriptions() {
        ServiceLocator.shared.relationDetailsStorage().stopSubscription()
        objectTypeProvider.stopSubscription()
    }
}
