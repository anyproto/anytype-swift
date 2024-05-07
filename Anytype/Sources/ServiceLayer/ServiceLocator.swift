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

    var documentsProvider: DocumentsProviderProtocol {
        Container.shared.documentsProvider()
    }
    
    // MARK: - Services
    
    var templatesService: TemplatesServiceProtocol {
        Container.shared.templatesService()
    }
    
    func seedService() -> SeedServiceProtocol {
        Container.shared.seedService()
    }
    
    /// creates new authService
    func authService() -> AuthServiceProtocol {
        Container.shared.authService()
    }
    
    func loginStateService() -> LoginStateServiceProtocol {
        Container.shared.loginStateService()
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
    
    func defaultObjectCreationService() -> DefaultObjectCreationServiceProtocol {
        Container.shared.defaultObjectCreationService()
    }
        
    func blockWidgetService() -> BlockWidgetServiceProtocol {
        Container.shared.blockWidgetService()
    }
    
    func favoriteSubscriptionService() -> FavoriteSubscriptionServiceProtocol {
        Container.shared.favoriteSubscriptionService()
    }
    
    func documentService() -> OpenedDocumentsProviderProtocol {
        Container.shared.documentService()
    }
    
    func fileErrorEventHandler() -> FileErrorEventHandlerProtocol {
        Container.shared.fileErrorEventHandler()
    }
    
    func deviceSceneStateListener() -> DeviceSceneStateListenerProtocol {
        Container.shared.deviceSceneStateListener()
    }
    
    func activeWorkspaceStorage() -> ActiveWorkpaceStorageProtocol {
        Container.shared.activeWorkspaceStorage()
    }
    
    func quickActionShortcutBuilder() -> QuickActionShortcutBuilderProtocol {
        Container.shared.quickActionShortcutBuilder()
    }
    
    func deepLinkParser() -> DeepLinkParserProtocol {
        Container.shared.deepLinkParser()
    }
    
    func relationValueProcessingService() -> RelationValueProcessingServiceProtocol {
        Container.shared.relationValueProcessingService()
    }
    
    func accountParticipantStorage() -> AccountParticipantsStorageProtocol {
        Container.shared.accountParticipantsStorage()
    }
}
