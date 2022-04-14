import Foundation
import UIKit
import BlocksModels
import AnytypeCore

final class ServiceLocator {
    static let shared = ServiceLocator()
    
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
            seedService: seedService(),
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
    
    func detailsService(objectId: AnytypeId) -> DetailsServiceProtocol {
        DetailsService(objectId: objectId, service: objectActionsService())
    }
    
    func subscriptionService() -> SubscriptionsServiceProtocol {
        SubscriptionsService(
            toggler: subscriptionToggler(),
            storage: detailsStorage()
        )
    }
    
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
