import AnytypeCore
import Services

protocol LoginStateServiceProtocol: AnyObject {
    var isFirstLaunchAfterRegistration: Bool { get }
    var isFirstLaunchAfterAuthorization: Bool { get }
    func setupStateAfterLoginOrAuth(account: AccountData) async
    func setupStateAfterAuth()
    func setupStateAfterRegistration(account: AccountData) async
    func cleanStateAfterLogout()
}

final class LoginStateService: LoginStateServiceProtocol {
    var isFirstLaunchAfterRegistration: Bool = false
    var isFirstLaunchAfterAuthorization: Bool = false
    
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol
    private let blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    private let workspacesStorage: WorkspacesStorageProtocol
    
    init(
        objectTypeProvider: ObjectTypeProviderProtocol,
        middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol,
        blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol,
        workspacesStorage: WorkspacesStorageProtocol
    ) {
        self.objectTypeProvider = objectTypeProvider
        self.middlewareConfigurationProvider = middlewareConfigurationProvider
        self.blockWidgetExpandedService = blockWidgetExpandedService
        self.relationDetailsStorage = relationDetailsStorage
        self.workspacesStorage = workspacesStorage
    }
    
    // MARK: - LoginStateServiceProtocol
    
    func setupStateAfterLoginOrAuth(account: AccountData) async {
        middlewareConfigurationProvider.setupConfiguration(account: account)
        await startSubscriptions()
    }
    
    func setupStateAfterAuth() {
        isFirstLaunchAfterAuthorization = true
    }
    
    func setupStateAfterRegistration(account: AccountData) async {
        isFirstLaunchAfterRegistration = true
        UserDefaultsConfig.showKeychainAlert = !FeatureFlags.newAuthorization 
        middlewareConfigurationProvider.setupConfiguration(account: account)
        await startSubscriptions()
    }
    
    func cleanStateAfterLogout() {
        UserDefaultsConfig.cleanStateAfterLogout()
        blockWidgetExpandedService.clearData()
        middlewareConfigurationProvider.removeCachedConfiguration()
        stopSubscriptions()
    }
    
    // MARK: - Private
    
    private func startSubscriptions() async {
        await workspacesStorage.startSubscription()
        await relationDetailsStorage.startSubscription()
        await objectTypeProvider.startSubscription()
    }
    
    private func stopSubscriptions() {
        workspacesStorage.stopSubscription()
        relationDetailsStorage.stopSubscription()
        objectTypeProvider.stopSubscription()
    }
}
