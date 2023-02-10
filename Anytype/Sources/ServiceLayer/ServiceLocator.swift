import Foundation
import UIKit
import BlocksModels
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
            accountManager: accountManager()
        )
    }
    
    func loginStateService() -> LoginStateServiceProtocol {
        LoginStateService(
            seedService: seedService(),
            objectTypeProvider: objectTypeProvider(),
            middlewareConfigurationProvider: middlewareConfigurationProvider(),
            blockWidgetExpandedService: blockWidgetExpandedService()
        )
    }
    
    func dashboardService() -> DashboardServiceProtocol {
        DashboardService(searchService: searchService(), pageService: pageService())
    }
    
    func blockActionsServiceSingle(contextId: BlockId) -> BlockActionsServiceSingleProtocol {
        BlockActionsServiceSingle(contextId: contextId)
    }
    
    func objectActionsService() -> ObjectActionsServiceProtocol {
        ObjectActionsService()
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
        DetailsService(objectId: objectId, service: objectActionsService())
    }
    
    func subscriptionService() -> SubscriptionsServiceProtocol {
        SubscriptionsService(
            toggler: subscriptionToggler(),
            storage: objectDetailsStorage()
        )
    }
    
    func bookmarkService() -> BookmarkServiceProtocol {
        BookmarkService()
    }
    
    func systemURLService() -> SystemURLServiceProtocol {
        SystemURLService()
    }
    
    func alertOpener() -> AlertOpenerProtocol {
        AlertOpener()
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
    
    func blockListService(documentId: String) -> BlockListServiceProtocol {
        return BlockListService(contextId: documentId)
    }
    
    func workspaceService() -> WorkspaceServiceProtocol {
        return WorkspaceService()
    }
    
    func pageService() -> PageServiceProtocol {
        return PageService()
    }
    
    func objectDetailsStorage() -> ObjectDetailsStorage {
        ObjectDetailsStorage.shared
    }
        
    func blockWidgetService() -> BlockWidgetServiceProtocol {
        return BlockWidgetService()
    }
    
    func favoriteSubscriptionService() -> FavoriteSubscriptionServiceProtocol {
        return FavoriteSubscriptionService(
            objectDetailsStorage: objectDetailsStorage(),
            objectTypeProvider: objectTypeProvider()
        )
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
    
    private lazy var _middlewareConfigurationProvider = MiddlewareConfigurationProvider()
    func middlewareConfigurationProvider() -> MiddlewareConfigurationProviderProtocol {
        return _middlewareConfigurationProvider
    }
    
    private lazy var _documentService = DocumentService()
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
    
    // MARK: - Private
    
    private func subscriptionToggler() -> SubscriptionTogglerProtocol {
        SubscriptionToggler()
    }
}
