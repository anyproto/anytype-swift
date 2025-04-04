import Foundation
// Automatically export Factory when import Servies
@_exported import Factory

public extension Container {
    
    var authMiddleService: Factory<AuthMiddleServiceProtocol> {
        self { AuthMiddleService() }.shared
    }
    
    var blockService: Factory<BlockServiceProtocol> {
        self { BlockService() }.shared
    }
    
    var blockTableService: Factory<BlockTableServiceProtocol> {
        self { BlockTableService() }.shared
    }
    
    var blockWidgetService: Factory<BlockWidgetServiceProtocol> {
        self { BlockWidgetService() }.shared
    }
    
    var bookmarkService: Factory<BookmarkServiceProtocol> {
        self { BookmarkService() }.shared
    }
    
    var dataviewService: Factory<DataviewServiceProtocol> {
        self { DataviewService() }.shared
    }
    
    var debugService: Factory<DebugServiceProtocol> {
        self { DebugService() }.shared
    }
    
    var fileService: Factory<FileServiceProtocol> {
        self { FileService() }.shared
    }
    
    var galleryService: Factory<GalleryServiceProtocol> {
        self { GalleryService() }.shared
    }
    
    var groupsSubscribeService: Factory<GroupsSubscribeServiceProtocol> {
        self { GroupsSubscribeService() }.shared
    }
    
    var metricsService: Factory<MetricsServiceProtocol> {
        self { MetricsService() }.shared
    }
    
    var middlewareConfigurationService: Factory<MiddlewareConfigurationServiceProtocol> {
        self { MiddlewareConfigurationService() }.shared
    }
    
    var notificationsService: Factory<NotificationsServiceProtocol> {
        self { NotificationsService() }.shared
    }
    
    var notificationsSubscriptionService: Factory<NotificationsSubscriptionServiceProtocol> {
        self { NotificationsSubscriptionService() }.shared
    }
    
    var objectActionsService: Factory<ObjectActionsServiceProtocol> {
        self { ObjectActionsService() }.shared
    }
    
    var objectLifecycleService: Factory<ObjectLifecycleServiceProtocol> {
        self { ObjectLifecycleService() }.shared
    }
    
    var objectSubscriptionService: Factory<ObjectSubscriptionServiceProtocol> {
        self { ObjectSubscriptionService() }.shared
    }
    
    var pasteboardMiddleService: Factory<PasteboardMiddlewareServiceProtocol> {
        self { PasteboardMiddleService() }.shared
    }
    
    var processSubscriptionService: Factory<ProcessSubscriptionServiceProtocol> {
        self { ProcessSubscriptionService() }.shared
    }
    
    var relationsService: Factory<RelationsServiceProtocol> {
        self { RelationsService() }.shared
    }
    
    var sceneLifecycleStateService: Factory<SceneLifecycleStateServiceProtocol> {
        self { SceneLifecycleStateService() }.shared
    }
    
    var searchMiddleService: Factory<SearchMiddleServiceProtocol> {
        self { SearchMiddleService() }.shared
    }
    
    var searchWithMetaMiddleService: Factory<SearchWithMetaMiddleServiceProtocol> {
        self { SearchWithMetaMiddleService() }.shared
    }
    
    var templatesService: Factory<TemplatesServiceProtocol> {
        self { TemplatesService() }.shared
    }
    
    var textService: Factory<TextServiceProtocol> {
        self { TextService() }.shared
    }
    
    var unsplashService: Factory<UnsplashServiceProtocol> {
        self { UnsplashService() }.shared
    }
    
    var workspaceService: Factory<WorkspaceServiceProtocol> {
        self { WorkspaceService() }.shared
    }
    
    var membershipService: Factory<MembershipServiceProtocol> {
        self { MembershipService() }.shared
    }
    
    var participantService: Factory<ParticipantServiceProtocol> {
        self { ParticipantService() }.shared
    }
    
    var objectIconBuilder: Factory<ObjectIconBuilderProtocol> {
        self { ObjectIconBuilder() }.shared
    }
    
    var historyVersionsService: Factory<HistoryVersionsServiceProtocol> {
        self { HistoryVersionsService() }.shared
    }
    
    var chatService: Factory<ChatServiceProtocol> {
        self { ChatService() }.shared
    }
    
    var relationListWithValueService: Factory<RelationListWithValueServiceProtocol> {
        self { RelationListWithValueService() }.shared
    }
    
    var objectDateByTimestampService: Factory<ObjectDateByTimestampServiceProtocol> {
        self { ObjectDateByTimestampService() }.shared
    }
    
    var spaceOrderService: Factory<SpaceOrderServiceProtocol> {
        self { SpaceOrderService() }.shared
    }
    
    var accountMigrationService: Factory<AccountMigrationServiceProtocol> {
        self { AccountMigrationService() }.shared
    }
    
    var aiService: Factory<AIServiceProtocol> {
        self { AIService() }.shared
    }
    
    var pushNotificationsService: Factory<PushNotificationsServiceProtocol> {
        self { PushNotificationsService() }.shared
    }
}
