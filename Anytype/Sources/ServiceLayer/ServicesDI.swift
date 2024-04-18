import Foundation
import SecureService
import Services
import SharedContentManager
import DeepLinks
import AnytypeCore
@_exported import Factory

extension Container {
    
    var activeWorkspaceStorage: Factory<ActiveWorkpaceStorageProtocol> {
        self { ActiveWorkspaceStorage() }.singleton
    }
    
    var accountManager: Factory<AccountManagerProtocol> {
        self { AccountManager() }.singleton
    }
    
    var accountEventHandler: Factory<AccountEventHandlerProtocol> {
        self { AccountEventHandler() }.singleton
    }
    
    var workspaceStorage: Factory<WorkspacesStorageProtocol> {
        self { WorkspacesStorage() }.singleton
    }
    
    var singleObjectSubscriptionService: Factory<SingleObjectSubscriptionServiceProtocol> {
        self { SingleObjectSubscriptionService() }
    }
    
    var loginStateService: Factory<LoginStateServiceProtocol> {
        self { LoginStateService() }.singleton
    }
    
    var subscriptionToggler: Factory<SubscriptionTogglerProtocol> {
        self { SubscriptionToggler() }.shared
    }
    
    var pasteboardHelper: Factory<PasteboardHelperProtocol> {
        self { PasteboardHelper() }
    }
    
    var pasteboardBlockService: Factory<PasteboardBlockServiceProtocol> {
        self { PasteboardBlockService() }
    }
    
    var localRepoService: Factory<LocalRepoServiceProtocol> {
        self { LocalRepoService() }.shared
    }
    
    var keychainStore: Factory<KeychainStoreProtocol> {
        self { KeychainStore() }.shared
    }
    
    var seedService: Factory<SeedServiceProtocol> {
        self { SeedService() }.shared
    }
    
    var usecaseService: Factory<UsecaseServiceProtocol> {
        self { UsecaseService() }.shared
    }
    
    var fileActionsService: Factory<FileActionsServiceProtocol> {
        self { FileActionsService() }.shared
    }
    
    var searchService: Factory<SearchServiceProtocol> {
        self { SearchService() }.shared
    }
    
    var subscriptionStorageProvider: Factory<SubscriptionStorageProviderProtocol> {
        self { SubscriptionStorageProvider() }.singleton
    }
    
    var systemURLService: Factory<SystemURLServiceProtocol> {
        self { SystemURLService() }.shared
    }
    
    var groupsSubscriptionsHandler: Factory<GroupsSubscriptionsHandlerProtocol> {
        self { GroupsSubscriptionsHandler() }
    }
    
    var objectTypeProvider: Factory<ObjectTypeProviderProtocol> {
        self { ObjectTypeProvider.shared }
    }
    
    var favoriteSubscriptionService: Factory<FavoriteSubscriptionServiceProtocol> {
        self { FavoriteSubscriptionService() }
    }
    
    var recentSubscriptionService: Factory<RecentSubscriptionServiceProtocol> {
        self { RecentSubscriptionService() }
    }
    
    var setsSubscriptionService: Factory<SetsSubscriptionServiceProtocol> {
        self { SetsSubscriptionService() }
    }
    
    var collectionsSubscriptionService: Factory<CollectionsSubscriptionServiceProtocol> {
        self { CollectionsSubscriptionService() }
    }
    
    var binSubscriptionService: Factory<BinSubscriptionServiceProtocol> {
        self { BinSubscriptionService() }
    }
    
    var treeSubscriptionDataBuilder: Factory<TreeSubscriptionDataBuilderProtocol> {
        self { TreeSubscriptionDataBuilder() }
    }
    
    var treeSubscriptionManager: Factory<TreeSubscriptionManagerProtocol> {
        self { TreeSubscriptionManager() }
    }
    
    var filesSubscriptionManager: Factory<FilesSubscriptionServiceProtocol> {
        self { FilesSubscriptionService() }
    }
    
    var templatesSubscription: Factory<TemplatesSubscriptionServiceProtocol> {
        self { TemplatesSubscriptionService() }
    }
    
    var defaultObjectCreationService: Factory<DefaultObjectCreationServiceProtocol> {
        self { DefaultObjectCreationService() }.shared
    }
    
    var appErrorLoggerConfiguration: Factory<AppErrorLoggerConfigurationProtocol> {
        self { AppErrorLoggerConfiguration() }.shared
    }
    
    var localAuthService: Factory<LocalAuthServiceProtocol> {
        self { LocalAuthService() }.shared
    }
    
    var cameraPermissionVerifier: Factory<CameraPermissionVerifierProtocol> {
        self { CameraPermissionVerifier() }.shared
    }
    
    var fileErrorEventHandler: Factory<FileErrorEventHandlerProtocol> {
        self { FileErrorEventHandler() }.singleton
    }
    
    var sceneStateNotifier: Factory<SceneStateNotifierProtocol> {
        self { SceneStateNotifier() }.singleton
    }
    
    var deviceSceneStateListener: Factory<DeviceSceneStateListenerProtocol> {
        self { DeviceSceneStateListener() }.singleton
    }
    
    var textServiceHandler: Factory<TextServiceProtocol> {
        self { TextServiceHandler() }.shared
    }
    
    var relationDetailsStorage: Factory<RelationDetailsStorageProtocol> {
        self { RelationDetailsStorage() }.singleton
    }
    
    var relationSubscriptionDataBuilder: Factory<RelationSubscriptionDataBuilderProtocol> {
        self { RelationSubscriptionDataBuilder() }
    }
    
    var middlewareConfigurationProvider: Factory<MiddlewareConfigurationProviderProtocol> {
        self { MiddlewareConfigurationProvider() }.singleton
    }
    
    var documentsProvider: Factory<DocumentsProviderProtocol> {
        self { DocumentsProvider() }.singleton
    }
    
    var blockWidgetExpandedService: Factory<BlockWidgetExpandedServiceProtocol> {
        self { BlockWidgetExpandedService() }.shared
    }
    
    var applicationStateService: Factory<ApplicationStateServiceProtocol> {
        self { ApplicationStateService() }.singleton
    }
    
    var documentService: Factory<OpenedDocumentsProviderProtocol> {
        self { OpenedDocumentsProvider() }.singleton
    }
    
    var typesPinsStorage: Factory<TypesPinStorageProtocol> {
        self { TypesPinStorage() }.shared
    }
    
    var objectsCommonSubscriptionDataBuilder: Factory<ObjectsCommonSubscriptionDataBuilderProtocol> {
        self { ObjectsCommonSubscriptionDataBuilder() }.shared
    }
    
    var sharedContentManager: Factory<SharedContentManagerProtocol> {
        self { SharingDI.shared.sharedContentManager() }
    }
    
    var typesService: Factory<TypesServiceProtocol> {
        self { TypesService() }.shared
    }
    
    var fileLimitsStorage: Factory<FileLimitsStorageProtocol> {
        self { FileLimitsStorage() }.shared
    }
    
    var workspacesSubscriptionBuilder: Factory<WorkspacesSubscriptionBuilderProtocol> {
        self { WorkspacesSubscriptionBuilder() }.shared
    }
    
    var serverConfigurationStorage: Factory<ServerConfigurationStorageProtocol> {
        self { ServerConfigurationStorage() }.singleton
    }
    
    var authService: Factory<AuthServiceProtocol> {
        self { AuthService() }.shared
    }
    
    var appActionStorage: Factory<AppActionStorage> {
        self { AppActionStorage() }.singleton
    }
    
    var quickActionShortcutBuilder: Factory<QuickActionShortcutBuilderProtocol> {
        self { QuickActionShortcutBuilder() }.shared
    }
    
    var deepLinkParser: Factory<DeepLinkParserProtocol> {
        self { DeepLinkDI.shared.parser(isDebug: CoreEnvironment.isDebug) }
    }
    
    var universalLinkParser: Factory<UniversalLinkParserProtocol> {
        self { UniversalLinkParser() }.shared
    }
    
    var detailsService: Factory<DetailsServiceProtocol> {
        self { DetailsService() }.shared
    }
    
    var pasteboardBlockDocumentService: Factory<PasteboardBlockDocumentServiceProtocol> {
        self { PasteboardBlockDocumentService() }.shared
    }
    
    var audioSessionService: Factory<AudioSessionServiceProtocol> {
        self { AudioSessionService() }.singleton
    }
    
    var textRelationEditingService: Factory<TextRelationEditingServiceProtocol> {
        self { TextRelationEditingService() }.shared
    }
    
    var accountParticipantsStorage: Factory<AccountParticipantsStorageProtocol> {
        self { AccountParticipantsStorage() }.singleton
    }
    
    var activeSpaceParticipantStorage: Factory<ActiveSpaceParticipantStorageProtocol> {
        self { ActiveSpaceParticipantStorage() }.singleton
    }

    var participantSpacesStorage: Factory<ParticipantSpacesStorageProtocol> {
        self { ParticipantSpacesStorage() }.singleton
    }
    
    var membershipStatusStorage: Factory<MembershipStatusStorageProtocol> {
        self { MembershipStatusStorage() }.shared
    }
    
    var objectHeaderUploadingService: Factory<ObjectHeaderUploadingServiceProtocol> {
        self { ObjectHeaderUploadingService() }.shared
    }
}
