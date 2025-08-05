import AnytypeCore
import Services

protocol LoginStateServiceProtocol: AnyObject, Sendable {
    var isFirstLaunchAfterRegistration: Bool { get }
    var isFirstLaunchAfterAuthorization: Bool { get }
    func setupStateAfterLoginOrAuth(account: AccountData) async
    func setupStateAfterAuth() async
    func setupStateAfterRegistration(account: AccountData) async
    func cleanStateAfterLogout() async
    func setupStateBeforeLoginOrAuth() async
}

final class LoginStateService: LoginStateServiceProtocol, Sendable {
    
    private let isFirstLaunchAfterRegistrationStorage = AtomicStorage(false)
    private let isFirstLaunchAfterAuthorizationStorage = AtomicStorage(false)
    
    var isFirstLaunchAfterRegistration: Bool {
        isFirstLaunchAfterRegistrationStorage.value
    }
    
    var isFirstLaunchAfterAuthorization: Bool {
        isFirstLaunchAfterAuthorizationStorage.value
    }
    
    private let objectTypeProvider: any ObjectTypeProviderProtocol = Container.shared.objectTypeProvider()
    private let middlewareConfigurationProvider: any MiddlewareConfigurationProviderProtocol = Container.shared.middlewareConfigurationProvider()
    private let blockWidgetExpandedService: any BlockWidgetExpandedServiceProtocol = Container.shared.blockWidgetExpandedService()
    private let membershipStatusStorage: any MembershipStatusStorageProtocol = Container.shared.membershipStatusStorage()
    private let propertyDetailsStorage: any PropertyDetailsStorageProtocol = Container.shared.propertyDetailsStorage()
    private let workspacesStorage: any WorkspacesStorageProtocol = Container.shared.workspaceStorage()
    private let accountParticipantsStorage: any AccountParticipantsStorageProtocol = Container.shared.accountParticipantsStorage()
    private let participantSpacesStorage: any ParticipantSpacesStorageProtocol = Container.shared.participantSpacesStorage()
    private let storeKitService: any StoreKitServiceProtocol = Container.shared.storeKitService()
    private let syncStatusStorage: any SyncStatusStorageProtocol = Container.shared.syncStatusStorage()
    private let p2pStatusStorage: any P2PStatusStorageProtocol = Container.shared.p2pStatusStorage()
    private let networkConnectionStatusDaemon: any NetworkConnectionStatusDaemonProtocol = Container.shared.networkConnectionStatusDaemon()
    private let userDefaults: any UserDefaultsStorageProtocol = Container.shared.userDefaultsStorage()
    private let activeSpaceManager: any ActiveSpaceManagerProtocol = Container.shared.activeSpaceManager()
    private let profileStorage: any ProfileStorageProtocol = Container.shared.profileStorage()
    private let basicUserInfoStorage: any BasicUserInfoStorageProtocol = Container.shared.basicUserInfoStorage()
    private let pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol = Container.shared.pushNotificationsPermissionService()
    private let spaceIconForNotificationsHandler: any SpaceIconForNotificationsHandlerProtocol = Container.shared.spaceIconForNotificationsHandler()
        
    // MARK: - LoginStateServiceProtocol
    
    func setupStateAfterLoginOrAuth(account: AccountData) async {
        middlewareConfigurationProvider.setupConfiguration(account: account)
        if #available(iOS 17.0, *) { WidgetSwipeTip.isFirstSession = false }
        
        await startSubscriptions()
    }
    
    func setupStateAfterAuth() async {
        isFirstLaunchAfterAuthorizationStorage.value = true
        if #available(iOS 17.0, *) { WidgetSwipeTip.isFirstSession = false }
    }
    
    func setupStateAfterRegistration(account: AccountData) async {
        isFirstLaunchAfterRegistrationStorage.value = true
        if #available(iOS 17.0, *) { WidgetSwipeTip.isFirstSession = true }
        middlewareConfigurationProvider.setupConfiguration(account: account)
        
        await startSubscriptions()
    }
    
    func cleanStateAfterLogout() async {
        userDefaults.cleanStateAfterLogout()
        basicUserInfoStorage.cleanUserIdAfterLogout()
        blockWidgetExpandedService.clearData()
        middlewareConfigurationProvider.removeCachedConfiguration()
        pushNotificationsPermissionService.unregisterForRemoteNotifications()
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
        await activeSpaceManager.startSubscription()
        await spaceIconForNotificationsHandler.startUpdating()
        
        Task {
            // Time-heavy operation
            #if RELEASE_ANYAPP
                await storeKitService.activatePromoTier()
            #endif
            await membershipStatusStorage.startSubscription()
        }
    }
    
    private func stopSubscriptions() async {
        await workspacesStorage.stopSubscription()
        await propertyDetailsStorage.stopSubscription()
        await objectTypeProvider.stopSubscription()
        await accountParticipantsStorage.stopSubscription()
        await participantSpacesStorage.stopSubscription()
        await membershipStatusStorage.stopSubscriptionAndClean()
        await syncStatusStorage.stopSubscriptionAndClean()
        await p2pStatusStorage.stopSubscriptionAndClean()
        await networkConnectionStatusDaemon.stop()
        await storeKitService.stopListenForTransactions()
        await profileStorage.stopSubscription()
        await activeSpaceManager.stopSubscription()
        await spaceIconForNotificationsHandler.stopUpdatingAndClearData()
    }
}
