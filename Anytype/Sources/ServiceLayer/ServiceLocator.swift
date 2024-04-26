import Foundation
import UIKit
import Services
import AnytypeCore
import SecureService
import SharedContentManager

// TODO: Migrate to ServicesDI
final class ServiceLocator {
    static let shared = ServiceLocator()

    let templatesService = TemplatesService()
    let sharedContentManager: SharedContentManagerProtocol = SharingDI.shared.sharedContentManager()

    lazy private(set) var unsplashService: UnsplashServiceProtocol = UnsplashService()
    lazy private(set) var documentsProvider: DocumentsProviderProtocol = DocumentsProvider(
        relationDetailsStorage: relationDetailsStorage(),
        objectTypeProvider: objectTypeProvider(),
        objectLifecycleService: objectLifecycleService()
    )
    
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
            appErrorLoggerConfiguration: appErrorLoggerConfiguration(),
            serverConfigurationStorage: serverConfigurationStorage(),
            authMiddleService: authMiddleService()
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
    
    func objectLifecycleService() -> ObjectLifecycleServiceProtocol {
        ObjectLifecycleService()
    }
    
    func objectActionsService() -> ObjectActionsServiceProtocol {
        ObjectActionsService()
    }
    
    func fileService() -> FileActionsServiceProtocol {
        FileActionsService(fileService: FileService())
    }
    
    func searchService() -> SearchServiceProtocol {
        SearchService(searchMiddleService: searchMiddleService())
    }
    
    func searchMiddleService() -> SearchMiddleServiceProtocol {
        SearchMiddleService()
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
    
    func blockService() -> BlockServiceProtocol {
        return BlockService()
    }
    
    func workspaceService() -> WorkspaceServiceProtocol {
        return WorkspaceService()
    }
    
    func typesService() -> TypesServiceProtocol {
        return TypesService(
            searchMiddleService: searchMiddleService(), 
            actionsService: objectActionsService(),
            pinsStorage: pinsStorage(),
            typeProvider: objectTypeProvider()
        )
    }
    
    func pinsStorage() -> TypesPinStorageProtocol {
        return TypesPinStorage(typeProvider: objectTypeProvider())
    }
    
    func defaultObjectCreationService() -> DefaultObjectCreationServiceProtocol {
        return DefaultObjectCreationService(
            objectTypeProvider: objectTypeProvider(),
            objectService: objectActionsService()
        )
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
    
    func participantSubscriptionService() -> ParticipantsSubscriptionServiceProtocol {
        return ParticipantsSubscriptionService(
            subscriptionStorageProvider: subscriptionStorageProvider(),
            activeWorkspaceStorage: activeWorkspaceStorage()
        )
    }
    
    private lazy var _middlewareConfigurationProvider = MiddlewareConfigurationProvider(middlewareConfigurationService: middlewareConfigurationService())
    func middlewareConfigurationProvider() -> MiddlewareConfigurationProviderProtocol {
        return _middlewareConfigurationProvider
    }
    
    private lazy var _documentService = OpenedDocumentsProvider(documentsProvider: documentsProvider)
    func documentService() -> OpenedDocumentsProviderProtocol {
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
    
    func dataviewService() -> DataviewServiceProtocol {
        DataviewService()
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
        return QuickActionShortcutBuilder(
            activeWorkspaceStorage: activeWorkspaceStorage(),
            typesService: typesService(),
            objectTypeProvider: objectTypeProvider()
        )
    }
    
    private lazy var _subscriptionStorageProvider = SubscriptionStorageProvider(toggler: subscriptionToggler())
    func subscriptionStorageProvider() -> SubscriptionStorageProviderProtocol {
        return _subscriptionStorageProvider
    }
    
    func templatesSubscription() -> TemplatesSubscriptionServiceProtocol {
        TemplatesSubscriptionService(subscriptionStorageProvider: subscriptionStorageProvider())
    }
    
    func setObjectCreationHelper() -> SetObjectCreationHelperProtocol {
        SetObjectCreationHelper(
            objectTypeProvider: objectTypeProvider(),
            dataviewService: dataviewService(),
            objectActionsService: objectActionsService(),
            prefilledFieldsBuilder: SetPrefilledFieldsBuilder(), 
            blockService: blockService()
        )
    }
    
    private lazy var _serverConfigurationStorage = ServerConfigurationStorage()
    func serverConfigurationStorage() -> ServerConfigurationStorage {
        return _serverConfigurationStorage
    }
    
    func middlewareConfigurationService() -> MiddlewareConfigurationServiceProtocol {
        MiddlewareConfigurationService()
    }
    
    func textServiceHandler() -> TextServiceProtocol {
        TextServiceHandler(textService: TextService())
    }
    
    func pasteboardMiddlewareService() -> PasteboardMiddlewareServiceProtocol {
        PasteboardMiddleService()
    }
    
    func galleryService() -> GalleryServiceProtocol {
        GalleryService()
    }
    
    func notificationSubscriptionService() -> NotificationsSubscriptionServiceProtocol {
        NotificationsSubscriptionService()
    }
    
    func deepLinkParser() -> DeepLinkParserProtocol {
        DeepLinkParser()
    }
    
    func processSubscriptionService() -> ProcessSubscriptionServiceProtocol {
        ProcessSubscriptionService()
    }
    
    func debugService() -> DebugServiceProtocol {
        DebugService()
    }
    
    // MARK: - Private
    
    private func subscriptionToggler() -> SubscriptionTogglerProtocol {
        SubscriptionToggler(objectSubscriptionService: objectSubscriptionService())
    }
    
    private func objectSubscriptionService() -> ObjectSubscriptionServiceProtocol {
        ObjectSubscriptionService()
    }
    
    private func authMiddleService() -> AuthMiddleServiceProtocol {
        AuthMiddleService()
    }
}
