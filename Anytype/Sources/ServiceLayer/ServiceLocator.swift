import Foundation
import UIKit
import Services
import AnytypeCore
import SecureService
import SharedContentManager
import DeepLinks

// TODO: Migrate to ServicesDI
final class ServiceLocator {
    static let shared = ServiceLocator()

    let sharedContentManager: SharedContentManagerProtocol = SharingDI.shared.sharedContentManager()

    lazy private(set) var documentsProvider: DocumentsProviderProtocol = DocumentsProvider(
        relationDetailsStorage: relationDetailsStorage(),
        objectTypeProvider: objectTypeProvider(),
        objectLifecycleService: objectLifecycleService()
    )
    
    // MARK: - Services
    
    var templatesService: TemplatesServiceProtocol {
        Container.shared.templatesService.resolve()
    }
    
    var unsplashService: UnsplashServiceProtocol {
        Container.shared.unsplashService.resolve()
    }
    
    
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
            authMiddleService: Container.shared.authMiddleService.resolve()
        )
    }
    
    func usecaseService() -> UsecaseServiceProtocol {
        UsecaseService()
    }
    
    func metricsService() -> MetricsServiceProtocol {
        Container.shared.metricsService.resolve()
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
        Container.shared.objectLifecycleService.resolve()
    }
    
    func objectActionsService() -> ObjectActionsServiceProtocol {
        Container.shared.objectActionsService.resolve()
    }
    
    func fileService() -> FileActionsServiceProtocol {
        FileActionsService(fileService: Container.shared.fileService.resolve())
    }
    
    func searchService() -> SearchServiceProtocol {
        SearchService(searchMiddleService: searchMiddleService())
    }
    
    func searchMiddleService() -> SearchMiddleServiceProtocol {
        Container.shared.searchMiddleService.resolve()
    }
    
    func detailsService(objectId: String) -> DetailsServiceProtocol {
        DetailsService(objectId: objectId, service: objectActionsService(), fileService: fileService())
    }
    
    func bookmarkService() -> BookmarkServiceProtocol {
        Container.shared.bookmarkService.resolve()
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
        GroupsSubscriptionsHandler(groupsSubscribeService: Container.shared.groupsSubscribeService.resolve())
    }
    
    func relationService() -> RelationsServiceProtocol {
        return Container.shared.relationsService.resolve()
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
        return Container.shared.blockService.resolve()
    }
    
    func workspaceService() -> WorkspaceServiceProtocol {
        return Container.shared.workspaceService.resolve()
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
        return Container.shared.blockWidgetService.resolve()
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
    
    func participantSubscriptionBySpaceService() -> ParticipantsSubscriptionBySpaceServiceProtocol {
        return ParticipantsSubscriptionBySpaceService(
            subscriptionStorageProvider: subscriptionStorageProvider(),
            activeWorkspaceStorage: activeWorkspaceStorage()
        )
    }
    
    func participantsSubscriptionByAccountService() -> ParticipantsSubscriptionByAccountServiceProtocol {
        return ParticipantsSubscriptionByAccountService(
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
    
    func objectHeaderInteractor(objectId: String) -> ObjectHeaderInteractorProtocol {
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
        Container.shared.dataviewService.resolve()
    }
    
    private lazy var _sceneStateNotifier = SceneStateNotifier()
    func sceneStateNotifier() -> SceneStateNotifierProtocol {
        _sceneStateNotifier
    }
    
    private lazy var _deviceSceneStateListener = DeviceSceneStateListener()
    func deviceSceneStateListener() -> DeviceSceneStateListenerProtocol {
        _deviceSceneStateListener
    }
    
    func audioSessionService() -> AudioSessionServiceProtocol {
        Container.shared.audioSessionService.resolve()
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
        Container.shared.middlewareConfigurationService.resolve()
    }
    
    func textServiceHandler() -> TextServiceProtocol {
        TextServiceHandler(textService: Container.shared.textService.resolve())
    }
    
    func pasteboardMiddlewareService() -> PasteboardMiddlewareServiceProtocol {
        Container.shared.pasteboardMiddleService.resolve()
    }
    
    func pasteboardHelper() -> PasteboardHelperProtocol {
        PasteboardHelper()
    }
    
    func pasteboardBlockDocumentService(document: BaseDocumentProtocol) -> PasteboardBlockDocumentServiceProtocol {
        PasteboardBlockDocumentService(
            document: document,
            service: pasteboardBlockService()
        )
    }
    
    func pasteboardBlockService() -> PasteboardBlockServiceProtocol {
        PasteboardBlockService(
            pasteboardHelper: pasteboardHelper(),
            pasteboardMiddlewareService: pasteboardMiddlewareService()
        )
    }
    
    func galleryService() -> GalleryServiceProtocol {
        Container.shared.galleryService.resolve()
    }
    
    func notificationSubscriptionService() -> NotificationsSubscriptionServiceProtocol {
        Container.shared.notificationsSubscriptionService.resolve()
    }
    
    func deepLinkParser() -> DeepLinkParserProtocol {
        DeepLinkDI.shared.parser(isDebug: CoreEnvironment.isDebug)
    }
    
    func processSubscriptionService() -> ProcessSubscriptionServiceProtocol {
        Container.shared.processSubscriptionService.resolve()
    }
    
    func debugService() -> DebugServiceProtocol {
        Container.shared.debugService.resolve()
    }
    
    func participantService() -> ParticipantServiceProtocol {
        Container.shared.participantService.resolve()
    }
    
    func blockTableService() -> BlockTableServiceProtocol {
        Container.shared.blockTableService.resolve()
    }
    
    // MARK: - Private
    
    private func subscriptionToggler() -> SubscriptionTogglerProtocol {
        SubscriptionToggler(objectSubscriptionService: objectSubscriptionService())
    }
    
    private func objectSubscriptionService() -> ObjectSubscriptionServiceProtocol {
        Container.shared.objectSubscriptionService.resolve()
    }
}
