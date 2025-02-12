import AnytypeCore
import Services

protocol LoginStateServiceProtocol: AnyObject, Sendable {
    var isFirstLaunchAfterRegistration: Bool { get }
    var isFirstLaunchAfterAuthorization: Bool { get }
    func setupStateAfterLoginOrAuth(account: AccountData) async
    func setupStateAfterAuth()
    func setupStateAfterRegistration(account: AccountData) async
    func cleanStateAfterLogout() async
    func setupStateBeforeLoginOrAuth() async
}

final class LoginStateService: LoginStateServiceProtocol, Sendable {
    var isFirstLaunchAfterRegistration: Bool = false
    var isFirstLaunchAfterAuthorization: Bool = false
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.middlewareConfigurationProvider)
    private var middlewareConfigurationProvider: any MiddlewareConfigurationProviderProtocol
    @Injected(\.blockWidgetExpandedService)
    private var blockWidgetExpandedService: any BlockWidgetExpandedServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: any MembershipStatusStorageProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.storeKitService)
    private var storeKitService: any StoreKitServiceProtocol
    @Injected(\.syncStatusStorage)
    private var syncStatusStorage: any SyncStatusStorageProtocol
    @Injected(\.p2pStatusStorage)
    private var p2pStatusStorage: any P2PStatusStorageProtocol
    @Injected(\.networkConnectionStatusDaemon)
    private var networkConnectionStatusDaemon: any NetworkConnectionStatusDaemonProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.profileStorage)
    private var profileStorage: any ProfileStorageProtocol
    
    // MARK: - LoginStateServiceProtocol
    
    func setupStateAfterLoginOrAuth(account: AccountData) async {
        middlewareConfigurationProvider.setupConfiguration(account: account)
        if #available(iOS 17.0, *) { WidgetSwipeTip.isFirstSession = false }
        
        await startSubscriptions()
    }
    
    func setupStateAfterAuth() {
        isFirstLaunchAfterAuthorization = true
        if #available(iOS 17.0, *) { WidgetSwipeTip.isFirstSession = false }
    }
    
    func setupStateAfterRegistration(account: AccountData) async {
        isFirstLaunchAfterRegistration = true
        if #available(iOS 17.0, *) { WidgetSwipeTip.isFirstSession = true }
        middlewareConfigurationProvider.setupConfiguration(account: account)
        await startSubscriptions()
    }
    
    func cleanStateAfterLogout() async {
        userDefaults.cleanStateAfterLogout()
        blockWidgetExpandedService.clearData()
        middlewareConfigurationProvider.removeCachedConfiguration()
        await spaceSetupManager.cleanupState()
        await stopSubscriptions()
    }
    
    func setupStateBeforeLoginOrAuth() async {
        await syncStatusStorage.startSubscription()
        await p2pStatusStorage.startSubscription()
    }
    
    // MARK: - Private
    
    private func startSubscriptions() async {
        await workspacesStorage.startSubscription()
        await accountParticipantsStorage.startSubscription()
        await participantSpacesStorage.startSubscription()
        await networkConnectionStatusDaemon.start()
        await storeKitService.startListenForTransactions()
        await profileStorage.startSubscription()
        
        Task {
            // Time-heavy operation
            await membershipStatusStorage.startSubscription()
        }
    }
    
    private func stopSubscriptions() async {
        await workspacesStorage.stopSubscription()
        await relationDetailsStorage.stopSubscription(cleanCache: true)
        await objectTypeProvider.stopSubscription(cleanCache: true)
        await accountParticipantsStorage.stopSubscription()
        await participantSpacesStorage.stopSubscription()
        await membershipStatusStorage.stopSubscriptionAndClean()
        await syncStatusStorage.stopSubscriptionAndClean()
        await p2pStatusStorage.stopSubscriptionAndClean()
        await networkConnectionStatusDaemon.stop()
        await storeKitService.stopListenForTransactions()
        await profileStorage.stopSubscription()
    }
}
