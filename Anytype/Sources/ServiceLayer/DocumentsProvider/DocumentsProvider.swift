import Foundation
import Services

protocol DocumentsProviderProtocol {
    func document(objectId: String, forPreview: Bool) -> BaseDocumentProtocol
    func setDocument(
        objectId: String,
        forPreview: Bool,
        inlineParameters: EditorInlineSetObject?
    ) -> SetDocumentProtocol
}

final class DocumentsProvider: DocumentsProviderProtocol {
    private var documentCache = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
    
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: RelationDetailsStorageProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: ObjectTypeProviderProtocol
    @Injected(\.objectLifecycleService)
    private var objectLifecycleService: ObjectLifecycleServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: AccountParticipantsStorageProtocol
    
    func document(objectId: String, forPreview: Bool) -> BaseDocumentProtocol {
        internalDocument(objectId: objectId, forPreview: forPreview)
    }
    
    func setDocument(
        objectId: String,
        forPreview: Bool,
        inlineParameters: EditorInlineSetObject?
    ) -> SetDocumentProtocol {
        let document = internalDocument(objectId: objectId, forPreview: forPreview)
        
        return SetDocument(
            document: document,
            inlineParameters: inlineParameters,
            relationDetailsStorage: relationDetailsStorage,
            objectTypeProvider: objectTypeProvider,
            accountParticipantsStorage: accountParticipantsStorage,
            permissionsBuilder: SetPermissionsBuilder()
        )
    }
    
    // MARK: - Private
    
    private func internalDocument(objectId: String, forPreview: Bool) -> BaseDocumentProtocol {
        if forPreview {
            let document = createBaseDocument(objectId: objectId, forPreview: forPreview)
            return document
        }
        
        if let value = documentCache.object(forKey: objectId as NSString) as? BaseDocumentProtocol {
            return value
        }
        
        let document = createBaseDocument(objectId: objectId, forPreview: forPreview)
        documentCache.setObject(document, forKey: objectId as NSString)
        
        return document
    }
    
    private func createBaseDocument(objectId: String, forPreview: Bool) -> BaseDocumentProtocol {
        let statusStorage = DocumentStatusStorage()
        let infoContainer = InfoContainer()
        let relationLinksStorage = RelationLinksStorage()
        let restrictionsContainer = ObjectRestrictionsContainer()
        let detailsStorage = ObjectDetailsStorage()
        let viewModelSetter = DocumentViewModelSetter(
            detailsStorage: detailsStorage,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer,
            infoContainer: infoContainer
        )
        let eventsListener = EventsListener(
            objectId: objectId,
            infoContainer: infoContainer,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer,
            detailsStorage: detailsStorage,
            statusStorage: statusStorage
        )
        return BaseDocument(
            objectId: objectId,
            forPreview: forPreview,
            objectLifecycleService: objectLifecycleService,
            relationDetailsStorage: relationDetailsStorage, 
            objectTypeProvider: objectTypeProvider,
            accountParticipantsStorage: accountParticipantsStorage,
            statusStorage: statusStorage,
            eventsListener: eventsListener,
            viewModelSetter: viewModelSetter,
            infoContainer: infoContainer,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer,
            detailsStorage: detailsStorage
        )
    }
}
