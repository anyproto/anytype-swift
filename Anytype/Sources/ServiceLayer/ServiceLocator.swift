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
            loginStateService: loginStateService()
        )
    }
    
    func loginStateService() -> LoginStateService {
        LoginStateService(seedService: seedService())
    }
    
    func dashboardService() -> DashboardServiceProtocol {
        DashboardService()
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
    
    func searchService() -> SearchService {
        SearchService()
    }
    
    func detailsService(objectId: BlockId) -> DetailsServiceProtocol {
        DetailsService(objectId: objectId, service: objectActionsService())
    }
    
    func subscriptionService() -> SubscriptionsServiceProtocol {
        SubscriptionsService(
            toggler: subscriptionToggler(),
            storage: detailsStorage()
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
    
    func pageService() -> PageServiceProtocol {
        return PageService()
    }
    
    // MARK: - Private
    
    private func subscriptionToggler() -> SubscriptionTogglerProtocol {
        SubscriptionToggler()
    }
    
    private func detailsStorage() -> ObjectDetailsStorage {
        ObjectDetailsStorage.shared
    }
    
    // MARK: - Coodrdinators
    
    func applicationCoordinator(window: UIWindow) -> ApplicationCoordinator {
        ApplicationCoordinator(window: window, authService: authService())
    }

}
