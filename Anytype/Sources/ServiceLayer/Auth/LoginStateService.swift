import AnytypeCore
import Services

protocol LoginStateServiceProtocol: AnyObject {
    var isFirstLaunchAfterRegistration: Bool { get }
    var isFirstLaunchAfterAuthorization: Bool { get }
    func setupStateAfterLoginOrAuth(account: AccountData) async
    func setupStateAfterAuth()
    func setupStateAfterRegistration(account: AccountData) async
    func cleanStateAfterLogout() async
}

final class LoginStateService: LoginStateServiceProtocol {
    var isFirstLaunchAfterRegistration: Bool = false
    var isFirstLaunchAfterAuthorization: Bool = false
    
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol
    private let blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    private let workspacesStorage: WorkspacesStorageProtocol
    private let activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    
    init(
        objectTypeProvider: ObjectTypeProviderProtocol,
        middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol,
        blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol,
        workspacesStorage: WorkspacesStorageProtocol,
        activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.objectTypeProvider = objectTypeProvider
        self.middlewareConfigurationProvider = middlewareConfigurationProvider
        self.blockWidgetExpandedService = blockWidgetExpandedService
        self.relationDetailsStorage = relationDetailsStorage
        self.workspacesStorage = workspacesStorage
        self.activeWorkpaceStorage = activeWorkpaceStorage
    }
    
    // MARK: - LoginStateServiceProtocol
    
    func setupStateAfterLoginOrAuth(account: AccountData) async {
        middlewareConfigurationProvider.setupConfiguration(account: account)
        await startSubscriptions()
        await activeWorkpaceStorage.setupActiveSpace()
    }
    
    func setupStateAfterAuth() {
        isFirstLaunchAfterAuthorization = true
    }
    
    func setupStateAfterRegistration(account: AccountData) async {
        isFirstLaunchAfterRegistration = true
        middlewareConfigurationProvider.setupConfiguration(account: account)
        await startSubscriptions()
        await activeWorkpaceStorage.setupActiveSpace()
    }
    
    func cleanStateAfterLogout() async {
        UserDefaultsConfig.cleanStateAfterLogout()
        blockWidgetExpandedService.clearData()
        middlewareConfigurationProvider.removeCachedConfiguration()
        await stopSubscriptions()
        await activeWorkpaceStorage.clearActiveSpace()
    }
    
    // MARK: - Private
    
    private func startSubscriptions() async {
        await workspacesStorage.startSubscription()
        await relationDetailsStorage.startSubscription()
        await objectTypeProvider.startSubscription()
    }
    
    private func stopSubscriptions() async {
        await workspacesStorage.stopSubscription()
        await relationDetailsStorage.stopSubscription()
        await objectTypeProvider.stopSubscription()
    }
}
