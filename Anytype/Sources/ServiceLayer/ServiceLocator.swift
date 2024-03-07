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

    var sharedContentManager: SharedContentManagerProtocol {
        Container.shared.sharedContentManager()
    }

    var documentsProvider: DocumentsProviderProtocol {
        Container.shared.documentsProvider()
    }
    
    // MARK: - Services
    
    var templatesService: TemplatesServiceProtocol {
        Container.shared.templatesService()
    }
    
    var unsplashService: UnsplashServiceProtocol {
        Container.shared.unsplashService()
    }
    
    /// creates new localRepoService
    func localRepoService() -> LocalRepoServiceProtocol {
        Container.shared.localRepoService()
    }
    
    func seedService() -> SeedServiceProtocol {
        Container.shared.seedService()
    }
    
    /// creates new authService
    func authService() -> AuthServiceProtocol {
        Container.shared.authService()
    }
    
    func usecaseService() -> UsecaseServiceProtocol {
        Container.shared.usecaseService()
    }
    
    func metricsService() -> MetricsServiceProtocol {
        Container.shared.metricsService()
    }
    
    func loginStateService() -> LoginStateServiceProtocol {
        Container.shared.loginStateService()
    }
    
    func objectLifecycleService() -> ObjectLifecycleServiceProtocol {
        Container.shared.objectLifecycleService()
    }
    
    func objectActionsService() -> ObjectActionsServiceProtocol {
        Container.shared.objectActionsService()
    }
    
    func fileService() -> FileActionsServiceProtocol {
        Container.shared.fileActionsService()
    }
    
    func searchService() -> SearchServiceProtocol {
        Container.shared.searchService()
    }
    
    func searchMiddleService() -> SearchMiddleServiceProtocol {
        Container.shared.searchMiddleService()
    }
    
    func detailsService() -> DetailsServiceProtocol {
        Container.shared.detailsService()
    }
    
    func bookmarkService() -> BookmarkServiceProtocol {
        Container.shared.bookmarkService()
    }
    
    func systemURLService() -> SystemURLServiceProtocol {
        Container.shared.systemURLService()
    }
    
    func accountManager() -> AccountManagerProtocol {
        Container.shared.accountManager()
    }
    
    func objectTypeProvider() -> ObjectTypeProviderProtocol {
        Container.shared.objectTypeProvider()
    }
    
    func groupsSubscriptionsHandler() -> GroupsSubscriptionsHandlerProtocol {
        Container.shared.groupsSubscriptionsHandler()
    }
    
    func relationService() -> RelationsServiceProtocol {
        Container.shared.relationsService()
    }
    
    func relationDetailsStorage() -> RelationDetailsStorageProtocol {
        Container.shared.relationDetailsStorage()
    }
    
    func accountEventHandler() -> AccountEventHandlerProtocol {
        Container.shared.accountEventHandler()
    }
    
    func blockService() -> BlockServiceProtocol {
        Container.shared.blockService()
    }
    
    func workspaceService() -> WorkspaceServiceProtocol {
        Container.shared.workspaceService()
    }
    
    func typesService() -> TypesServiceProtocol {
        Container.shared.typesService()
    }
    
    func pinsStorage() -> TypesPinStorageProtocol {
        Container.shared.typesPinsStorage()
    }
    
    func defaultObjectCreationService() -> DefaultObjectCreationServiceProtocol {
        Container.shared.defaultObjectCreationService()
    }
        
    func blockWidgetService() -> BlockWidgetServiceProtocol {
        Container.shared.blockWidgetService()
    }
    
    func favoriteSubscriptionService() -> FavoriteSubscriptionServiceProtocol {
        Container.shared.favoriteSubscriptionService()
    }
    
    func recentSubscriptionService() -> RecentSubscriptionServiceProtocol {
        Container.shared.recentSubscriptionService()
    }
    
    func setsSubscriptionService() -> SetsSubscriptionServiceProtocol {
        Container.shared.setsSubscriptionService()
    }
    
    func collectionsSubscriptionService() -> CollectionsSubscriptionServiceProtocol {
        Container.shared.collectionsSubscriptionService()
    }
    
    func binSubscriptionService() -> BinSubscriptionServiceProtocol {
        Container.shared.binSubscriptionService()
    }
    
    func treeSubscriptionManager() -> TreeSubscriptionManagerProtocol {
        Container.shared.treeSubscriptionManager()
    }
    
    func filesSubscriptionManager() -> FilesSubscriptionServiceProtocol {
        Container.shared.filesSubscriptionManager()
    }
    
    func participantSubscriptionBySpaceService() -> ParticipantsSubscriptionBySpaceServiceProtocol {
        Container.shared.participantSubscriptionBySpaceService()
    }
    
    func participantsSubscriptionByAccountService() -> ParticipantsSubscriptionByAccountServiceProtocol {
        Container.shared.participantsSubscriptionByAccountService()
    }
    
    func middlewareConfigurationProvider() -> MiddlewareConfigurationProviderProtocol {
        Container.shared.middlewareConfigurationProvider()
    }
    
    func documentService() -> OpenedDocumentsProviderProtocol {
        Container.shared.documentService()
    }
    
    func blockWidgetExpandedService() -> BlockWidgetExpandedServiceProtocol {
        Container.shared.blockWidgetExpandedService()
    }
    
    func applicationStateService() -> ApplicationStateServiceProtocol {
        Container.shared.applicationStateService()
    }
    
    func appActionStorage() -> AppActionStorage {
        Container.shared.appActionStorage()
    }
    
    func objectsCommonSubscriptionDataBuilder() -> ObjectsCommonSubscriptionDataBuilderProtocol {
        Container.shared.objectsCommonSubscriptionDataBuilder()
    }
    
    func objectHeaderInteractor() -> ObjectHeaderInteractorProtocol {
        Container.shared.objectHeaderInteractor()
    }
    
    func singleObjectSubscriptionService() -> SingleObjectSubscriptionServiceProtocol {
        Container.shared.singleObjectSubscriptionService()
    }
    
    func fileLimitsStorage() -> FileLimitsStorageProtocol {
        Container.shared.fileLimitsStorage()
    }
    
    func fileErrorEventHandler() -> FileErrorEventHandlerProtocol {
        Container.shared.fileErrorEventHandler()
    }
    
    func appErrorLoggerConfiguration() -> AppErrorLoggerConfigurationProtocol {
        Container.shared.appErrorLoggerConfiguration()
    }
    
    func localAuthService() -> LocalAuthServiceProtocol {
        Container.shared.localAuthService()
    }
    
    func cameraPermissionVerifier() -> CameraPermissionVerifierProtocol {
        Container.shared.cameraPermissionVerifier()
    }
    
    func dataviewService() -> DataviewServiceProtocol {
        Container.shared.dataviewService()
    }
    
    func sceneStateNotifier() -> SceneStateNotifierProtocol {
        Container.shared.sceneStateNotifier()
    }
    
    func deviceSceneStateListener() -> DeviceSceneStateListenerProtocol {
        Container.shared.deviceSceneStateListener()
    }
    
    func audioSessionService() -> AudioSessionServiceProtocol {
        Container.shared.audioSessionService()
    }
    
    func activeWorkspaceStorage() -> ActiveWorkpaceStorageProtocol {
        Container.shared.activeWorkpaceStorage()
    }
    
    func workspaceStorage() -> WorkspacesStorageProtocol {
        Container.shared.workspaceStorage()
    }
    
    func quickActionShortcutBuilder() -> QuickActionShortcutBuilderProtocol {
        Container.shared.quickActionShortcutBuilder()
    }
    
    func subscriptionStorageProvider() -> SubscriptionStorageProviderProtocol {
        Container.shared.subscriptionStorageProvider()
    }
    
    func templatesSubscription() -> TemplatesSubscriptionServiceProtocol {
        TemplatesSubscriptionService(subscriptionStorageProvider: subscriptionStorageProvider())
    }
    
    func setObjectCreationHelper() -> SetObjectCreationHelperProtocol {
        Container.shared.setObjectCreationHelper()
    }
    
    func serverConfigurationStorage() -> ServerConfigurationStorageProtocol {
        Container.shared.serverConfigurationStorage()
    }
    
    func middlewareConfigurationService() -> MiddlewareConfigurationServiceProtocol {
        Container.shared.middlewareConfigurationService()
    }
    
    func textServiceHandler() -> TextServiceProtocol {
        Container.shared.textServiceHandler()
    }
    
    func pasteboardMiddlewareService() -> PasteboardMiddlewareServiceProtocol {
        Container.shared.pasteboardMiddleService()
    }
    
    func pasteboardHelper() -> PasteboardHelperProtocol {
        Container.shared.pasteboardHelper()
    }
    
    func pasteboardBlockDocumentService() -> PasteboardBlockDocumentServiceProtocol {
        Container.shared.pasteboardBlockDocumentService()
    }
    
    func pasteboardBlockService() -> PasteboardBlockServiceProtocol {
        Container.shared.pasteboardBlockService()
    }
    
    func galleryService() -> GalleryServiceProtocol {
        Container.shared.galleryService()
    }
    
    func notificationSubscriptionService() -> NotificationsSubscriptionServiceProtocol {
        Container.shared.notificationsSubscriptionService()
    }
    
    func deepLinkParser() -> DeepLinkParserProtocol {
        Container.shared.deepLinkParser()
    }
    
    func processSubscriptionService() -> ProcessSubscriptionServiceProtocol {
        Container.shared.processSubscriptionService()
    }
    
    func debugService() -> DebugServiceProtocol {
        Container.shared.debugService()
    }
    
    func participantService() -> ParticipantServiceProtocol {
        Container.shared.participantService()
    }
    
    func blockTableService() -> BlockTableServiceProtocol {
        Container.shared.blockTableService()
    }
    
    func relationValueProcessingService() -> RelationValueProcessingServiceProtocol {
        Container.shared.relationValueProcessingService()
    }
    
    func membershipService() -> MembershipServiceProtocol {
        Container.shared.membershipService()
    }
}
