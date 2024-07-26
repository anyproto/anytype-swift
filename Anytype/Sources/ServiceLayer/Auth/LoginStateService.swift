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
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkpaceStorage: any ActiveWorkpaceStorageProtocol
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
        middlewareConfigurationProvider.setupConfiguration(account: account)
        await startSubscriptions()
    }
    
    func cleanStateAfterLogout() async {
        UserDefaultsConfig.cleanStateAfterLogout()
        blockWidgetExpandedService.clearData()
        middlewareConfigurationProvider.removeCachedConfiguration()
        await stopSubscriptions()
    }
    
    // MARK: - Private
    
    private func startSubscriptions() async {
        await workspacesStorage.startSubscription()
        await relationDetailsStorage.startSubscription()
        await objectTypeProvider.startSubscription()
        await activeWorkpaceStorage.setupActiveSpace()
        await accountParticipantsStorage.startSubscription()
        await participantSpacesStorage.startSubscription()
        await syncStatusStorage.startSubscription()
        await p2pStatusStorage.startSubscription()
        await networkConnectionStatusDaemon.start()
        storeKitService.startListenForTransactions()
        
        Task {
            // Time-heavy operation
            await membershipStatusStorage.startSubscription()
        }
    }
    
    private func stopSubscriptions() async {
        await workspacesStorage.stopSubscription()
        await relationDetailsStorage.stopSubscription()
        await objectTypeProvider.stopSubscription()
        await activeWorkpaceStorage.clearActiveSpace()
        await accountParticipantsStorage.stopSubscription()
        await participantSpacesStorage.stopSubscription()
        await membershipStatusStorage.stopSubscriptionAndClean()
        await syncStatusStorage.stopSubscriptionAndClean()
        await p2pStatusStorage.stopSubscriptionAndClean()
        await networkConnectionStatusDaemon.stop()
        storeKitService.stopListenForTransactions()
    }
}
