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
    private var objectTypeProvider: ObjectTypeProviderProtocol
    @Injected(\.middlewareConfigurationProvider)
    private var middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol
    @Injected(\.blockWidgetExpandedService)
    private var blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: MembershipStatusStorageProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: RelationDetailsStorageProtocol
    @Injected(\.workspaceStorage)
    private var workspacesStorage: WorkspacesStorageProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: AccountParticipantsStorageProtocol
    @Injected(\.activeSpaceParticipantStorage)
    private var activeSpaceParticipantStorage: ActiveSpaceParticipantStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: ParticipantSpacesStorageProtocol
    @Injected(\.storeKitService)
    private var storeKitService: StoreKitServiceProtocol
    
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
        await activeSpaceParticipantStorage.startSubscription()
        await participantSpacesStorage.startSubscription()
        storeKitService.startListenForTransactions()
        
        Task {
            await membershipStatusStorage.startSubscription()
        }
    }
    
    private func stopSubscriptions() async {
        await workspacesStorage.stopSubscription()
        await relationDetailsStorage.stopSubscription()
        await objectTypeProvider.stopSubscription()
        await activeWorkpaceStorage.clearActiveSpace()
        await accountParticipantsStorage.stopSubscription()
        await activeSpaceParticipantStorage.stopSubscription()
        await participantSpacesStorage.stopSubscription()
        await membershipStatusStorage.stopSubscriptionAndClean()
        storeKitService.stopListenForTransactions()
    }
}
