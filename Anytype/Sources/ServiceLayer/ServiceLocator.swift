import Foundation
import UIKit
import Services
import AnytypeCore
import SecureService

// TODO: Migrate to ServicesDI
final class ServiceLocator {
    static let shared = ServiceLocator()

    let textService = TextService()
    let templatesService = TemplatesService()
    let sharedContentManager: SharedContentManagerProtocol = SharedContentManager()
    lazy private(set) var sharedContentInteractor: SharedContentInteractorProtocol = SharedContentInteractor(
        listService: blockListService(),
        bookmarkService: bookmarkService(),
        objectActionsService: objectActionsService(),
        blockActionService: blockActionsServiceSingle(),
        pageRepository: pageRepository(),
        activeWorkpaceStorage: activeWorkspaceStorage()
    )
    lazy private(set) var unsplashService: UnsplashServiceProtocol = UnsplashService()
    
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
        relationDetailsStorage: relationDetailsStorage(),
        workspacesStorage: workspaceStorage(),
        activeWorkpaceStorage: activeWorkspaceStorage()
    )
    func loginStateService() -> LoginStateServiceProtocol {
        return _loginStateService
    }
    
    func dashboardService() -> DashboardServiceProtocol {
        DashboardService(searchService: searchService(), pageService: pageRepository())
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
        SearchService()
    }
    
    func detailsService(objectId: BlockId) -> DetailsServiceProtocol {
        DetailsService(objectId: objectId, service: objectActionsService(), fileService: fileService())
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
        subscriptionStorageProvider: subscriptionStorageProvider(),
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
    
    func pageRepository() -> PageRepositoryProtocol {
        return PageRepository(objectTypeProvider: objectTypeProvider(), pageService: PageService())
    }
        
    func blockWidgetService() -> BlockWidgetServiceProtocol {
        return BlockWidgetService()
    }
    
    func favoriteSubscriptionService() -> FavoriteSubscriptionServiceProtocol {
        return FavoriteSubscriptionService()
    }
    
    func recentSubscriptionService() -> RecentSubscriptionServiceProtocol {
        return RecentSubscriptionService(
            subscriptionStorageProvider: subscriptionStorageProvider(),
            activeWorkspaceStorage: activeWorkspaceStorage(),
            objectTypeProvider: objectTypeProvider()
        )
    }
    
    func setsSubscriptionService() -> SetsSubscriptionServiceProtocol {
        return SetsSubscriptionService(
            subscriptionStorageProvider: subscriptionStorageProvider(),
            activeWorkspaceStorage: activeWorkspaceStorage(),
            objectTypeProvider: objectTypeProvider()
        )
    }
    
    func collectionsSubscriptionService() -> CollectionsSubscriptionServiceProtocol {
        return CollectionsSubscriptionService(
            subscriptionStorageProvider: subscriptionStorageProvider(),
            activeWorkspaceStorage: activeWorkspaceStorage(),
            objectTypeProvider: objectTypeProvider()
        )
    }
    
    func binSubscriptionService() -> BinSubscriptionServiceProtocol {
        return BinSubscriptionService(
            subscriptionStorageProvider: subscriptionStorageProvider(),
            activeWorkspaceStorage: activeWorkspaceStorage()
        )
    }
    
    func treeSubscriptionManager() -> TreeSubscriptionManagerProtocol {
        return TreeSubscriptionManager(
            subscriptionDataBuilder: TreeSubscriptionDataBuilder(),
            subscriptionStorageProvider: subscriptionStorageProvider()
        )
    }
    
    func filesSubscriptionManager() -> FilesSubscriptionServiceProtocol {
        return FilesSubscriptionService(
            subscriptionStorageProvider: subscriptionStorageProvider(),
            activeWorkspaceStorage: activeWorkspaceStorage()
        )
    }
    
    private lazy var _middlewareConfigurationProvider = MiddlewareConfigurationProvider()
    func middlewareConfigurationProvider() -> MiddlewareConfigurationProviderProtocol {
        return _middlewareConfigurationProvider
    }
    
    private lazy var _documentService = DocumentService(relationDetailsStorage: relationDetailsStorage(), objectTypeProvider: objectTypeProvider())
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
    
    func appActionStorage() -> AppActionStorage {
        AppActionStorage.shared
    }
    
    func objectsCommonSubscriptionDataBuilder() -> ObjectsCommonSubscriptionDataBuilderProtocol {
        ObjectsCommonSubscriptionDataBuilder()
    }
    
    func objectHeaderInteractor(objectId: BlockId) -> ObjectHeaderInteractorProtocol {
        ObjectHeaderInteractor(
            detailsService: detailsService(objectId: objectId),
            fileService: fileService(),
            unsplashService: unsplashService
        )
    }
    
    func singleObjectSubscriptionService() -> SingleObjectSubscriptionServiceProtocol {
        SingleObjectSubscriptionService(
            subscriptionStorageProvider: subscriptionStorageProvider(),
            subscriotionBuilder: objectsCommonSubscriptionDataBuilder()
        )
    }
    
    func fileLimitsStorage() -> FileLimitsStorageProtocol {
        return FileLimitsStorage(fileService: fileService())
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
    
    func dataviewService(objectId: BlockId, blockId: BlockId?) -> DataviewServiceProtocol {
        DataviewService(
            objectId: objectId,
            blockId: blockId,
            prefilledFieldsBuilder: SetPrefilledFieldsBuilder()
        )
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
    
    // In future lifecycle should be depend for screen
    private lazy var _activeWorkspaceStorage = ActiveWorkspaceStorage(
        workspaceStorage: workspaceStorage(),
        accountManager: accountManager(),
        workspaceService: workspaceService()
    )
    func activeWorkspaceStorage() -> ActiveWorkpaceStorageProtocol {
        return _activeWorkspaceStorage
    }

    private lazy var _workspaceStorage = WorkspacesStorage(
        subscriptionStorageProvider: subscriptionStorageProvider(),
        subscriptionBuilder: WorkspacesSubscriptionBuilder()
    )
    func workspaceStorage() -> WorkspacesStorageProtocol {
        return _workspaceStorage
    }
    
    func quickActionShortcutBuilder() -> QuickActionShortcutBuilderProtocol {
        return QuickActionShortcutBuilder(activeWorkspaceStorage: activeWorkspaceStorage(), objectTypeProvider: objectTypeProvider())
    }
    
    private lazy var _subscriptionStorageProvider = SubscriptionStorageProvider(toggler: subscriptionToggler())
    func subscriptionStorageProvider() -> SubscriptionStorageProviderProtocol {
        return _subscriptionStorageProvider
    }
    
    func templatesSubscription() -> TemplatesSubscriptionServiceProtocol {
        TemplatesSubscriptionService(subscriptionStorageProvider: subscriptionStorageProvider())
    }
    
    // MARK: - Private
    
    private func subscriptionToggler() -> SubscriptionTogglerProtocol {
        SubscriptionToggler(objectSubscriptionService: objectSubscriptionService())
    }
    
    private func objectSubscriptionService() -> ObjectSubscriptionServiceProtocol {
        ObjectSubscriptionService()
    }
}
