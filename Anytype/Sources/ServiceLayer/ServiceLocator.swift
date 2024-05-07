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
    
    func objectActionsService() -> ObjectActionsServiceProtocol {
        Container.shared.objectActionsService()
    }
    
    func accountEventHandler() -> AccountEventHandlerProtocol {
        Container.shared.accountEventHandler()
    }
    
    func defaultObjectCreationService() -> DefaultObjectCreationServiceProtocol {
        Container.shared.defaultObjectCreationService()
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
