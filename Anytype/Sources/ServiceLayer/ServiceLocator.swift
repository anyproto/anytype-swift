import Foundation
import UIKit
import Services
import AnytypeCore

// TODO: Migrate to ServicesDI
final class ServiceLocator {
    static let shared = ServiceLocator()

    let textService = TextService()
    
    // MARK: - Services
    
    /// creates new localRepoService
    func localRepoService() -> LocalRepoServiceProtocol {
        LocalRepoService()
    }
    
    func seedService() -> SeedServiceProtocol {
        SeedService(keychainStore: KeychainStore())
    }
    
    /// creates new authService
    func authService() -> AuthServiceProtocol {
        return AuthService(
            localRepoService: localRepoService(),
            loginStateService: loginStateService(),
            accountManager: accountManager(),
            appErrorLoggerConfiguration: appErrorLoggerConfiguration()
        )
    }
    
    func usecaseService() -> UsecaseServiceProtocol {
        UsecaseService()
    }
    
    func metricsService() -> MetricsServiceProtocol {
        MetricsService()
    }
    
    private lazy var _loginStateService = LoginStateService(
        objectTypeProvider: objectTypeProvider(),
        middlewareConfigurationProvider: middlewareConfigurationProvider(),
        blockWidgetExpandedService: blockWidgetExpandedService(),
        relationDetailsStorage: relationDetailsStorage()
    )
    func loginStateService() -> LoginStateServiceProtocol {
        return _loginStateService
    }
    
    func dashboardService() -> DashboardServiceProtocol {
        DashboardService(searchService: searchService(), pageService: pageService(), objectTypeProvider: objectTypeProvider())
    }
    
    func blockActionsServiceSingle() -> BlockActionsServiceSingleProtocol {
        BlockActionsServiceSingle()
    }
    
    func objectActionsService() -> ObjectActionsServiceProtocol {
        ObjectActionsService(objectTypeProvider: objectTypeProvider())
    }
    
    func fileService() -> FileActionsServiceProtocol {
        FileActionsService()
    }
    
    func searchService() -> SearchServiceProtocol {
        SearchService(
            accountManager: accountManager(),
            objectTypeProvider: objectTypeProvider(),
            relationDetailsStorage: relationDetailsStorage()
        )
    }
    
    func detailsService(objectId: BlockId) -> DetailsServiceProtocol {
        DetailsService(objectId: objectId, service: objectActionsService(), fileService: fileService())
    }
    
    func subscriptionService() -> SubscriptionsServiceProtocol {
        SubscriptionsService(
            toggler: subscriptionToggler(),
            storage: ObjectDetailsStorage()
        )
    }
    
    func bookmarkService() -> BookmarkServiceProtocol {
        BookmarkService()
    }
    
    func systemURLService() -> SystemURLServiceProtocol {
        SystemURLService()
    }
    
    private lazy var _accountManager = AccountManager()
    func accountManager() -> AccountManagerProtocol {
        return _accountManager
    }
    
    func objectTypeProvider() -> ObjectTypeProviderProtocol {
        return ObjectTypeProvider.shared
    }
    
    func groupsSubscriptionsHandler() -> GroupsSubscriptionsHandlerProtocol {
        GroupsSubscriptionsHandler(groupsSubscribeService: GroupsSubscribeService())
    }
    
    func relationService(objectId: String) -> RelationsServiceProtocol {
        return RelationsService(objectId: objectId)
    }
    
    // Sigletone
    private lazy var _relationDetailsStorage = RelationDetailsStorage(
        subscriptionsService: subscriptionService(),
        subscriptionDataBuilder: RelationSubscriptionDataBuilder(accountManager: accountManager())
    )
    func relationDetailsStorage() -> RelationDetailsStorageProtocol {
        return _relationDetailsStorage
    }
    
    private lazy var _accountEventHandler = AccountEventHandler(
        accountManager: accountManager()
    )
    func accountEventHandler() -> AccountEventHandlerProtocol {
        return _accountEventHandler
    }
    
    func blockListService() -> BlockListServiceProtocol {
        return BlockListService()
    }
    
    func workspaceService() -> WorkspaceServiceProtocol {
        return WorkspaceService()
    }
    
    func pageService() -> PageServiceProtocol {
        return PageService(objectTypeProvider: objectTypeProvider())
    }
        
    func blockWidgetService() -> BlockWidgetServiceProtocol {
        return BlockWidgetService()
    }
    
    func favoriteSubscriptionService() -> FavoriteSubscriptionServiceProtocol {
        return FavoriteSubscriptionService()
    }
    
    func recentSubscriptionService() -> RecentSubscriptionServiceProtocol {
        return RecentSubscriptionService(
            subscriptionService: subscriptionService(),
            accountManager: accountManager(),
            objectTypeProvider: objectTypeProvider()
        )
    }
    
    func setsSubscriptionService() -> SetsSubscriptionServiceProtocol {
        return SetsSubscriptionService(
            subscriptionService: subscriptionService(),
            accountManager: accountManager(),
            objectTypeProvider: objectTypeProvider()
        )
    }
    
    func collectionsSubscriptionService() -> CollectionsSubscriptionServiceProtocol {
        return CollectionsSubscriptionService(
            subscriptionService: subscriptionService(),
            accountManager: accountManager(),
            objectTypeProvider: objectTypeProvider()
        )
    }
    
    func binSubscriptionService() -> BinSubscriptionServiceProtocol {
        return BinSubscriptionService(
            subscriptionService: subscriptionService(),
            accountManager: accountManager()
        )
    }
    
    func treeSubscriptionManager() -> TreeSubscriptionManagerProtocol {
        return TreeSubscriptionManager(
            subscriptionDataBuilder: TreeSubscriptionDataBuilder(),
            subscriptionService: subscriptionService()
        )
    }
    
    func filesSubscriptionManager() -> FilesSubscriptionServiceProtocol {
        return FilesSubscriptionService(subscriptionService: subscriptionService(), accountManager: accountManager())
    }
    
    private lazy var _middlewareConfigurationProvider = MiddlewareConfigurationProvider()
    func middlewareConfigurationProvider() -> MiddlewareConfigurationProviderProtocol {
        return _middlewareConfigurationProvider
    }
    
    private lazy var _documentService = DocumentService(relationDetailsStorage: relationDetailsStorage())
    func documentService() -> DocumentServiceProtocol {
        return _documentService
    }
    
    private lazy var _blockWidgetExpandedService = BlockWidgetExpandedService()
    func blockWidgetExpandedService() -> BlockWidgetExpandedServiceProtocol {
        return _blockWidgetExpandedService
    }
    
    private lazy var _applicationStateService = ApplicationStateService()
    func applicationStateService() -> ApplicationStateServiceProtocol {
        _applicationStateService
    }
    
    func quickActionStorage() -> QuickActionsStorage {
        QuickActionsStorage.shared
    }
    
    func objectsCommonSubscriptionDataBuilder() -> ObjectsCommonSubscriptionDataBuilderProtocol {
        ObjectsCommonSubscriptionDataBuilder()
    }
    
    func singleObjectSubscriptionService() -> SingleObjectSubscriptionServiceProtocol {
        SingleObjectSubscriptionService(subscriptionService: subscriptionService(), subscriotionBuilder: objectsCommonSubscriptionDataBuilder())
    }
    
    private weak var _fileLimitsStorage: FileLimitsStorageProtocol?
    func fileLimitsStorage() -> FileLimitsStorageProtocol {
        let storage = _fileLimitsStorage ?? FileLimitsStorage(fileService: fileService())
        _fileLimitsStorage = storage
        return storage
    }
    
    private lazy var _fileErrorEventHandler = FileErrorEventHandler()
    func fileErrorEventHandler() -> FileErrorEventHandlerProtocol {
        _fileErrorEventHandler
    }
    
    func appErrorLoggerConfiguration() -> AppErrorLoggerConfigurationProtocol {
        AppErrorLoggerConfiguration()
    }
    
    func localAuthService() -> LocalAuthServiceProtocol {
        LocalAuthService()
    }
    
    func cameraPermissionVerifier() -> CameraPermissionVerifierProtocol {
        CameraPermissionVerifier()
    }
    
    
    private lazy var _sceneStateNotifier = SceneStateNotifier()
    func sceneStateNotifier() -> SceneStateNotifierProtocol {
        _sceneStateNotifier
    }
    
    private lazy var _deviceSceneStateListener = DeviceSceneStateListener()
    func deviceSceneStateListener() -> DeviceSceneStateListenerProtocol {
        _deviceSceneStateListener
    }
    
    private lazy var _audioSessionService = AudioSessionService()
    func audioSessionService() -> AudioSessionServiceProtocol {
        _audioSessionService
    }
    
    // MARK: - Private
    
    private func subscriptionToggler() -> SubscriptionTogglerProtocol {
        SubscriptionToggler()
    }
}
