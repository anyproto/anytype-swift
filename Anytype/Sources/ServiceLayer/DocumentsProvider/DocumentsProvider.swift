import Foundation
import Services

protocol DocumentsProviderProtocol {
    func document(objectId: String, mode: DocumentMode) -> any BaseDocumentProtocol
    func setDocument(
        objectId: String,
        mode: DocumentMode,
        inlineParameters: EditorInlineSetObject?
    ) -> any SetDocumentProtocol
}

extension DocumentsProviderProtocol {
    func document(objectId: String) -> any BaseDocumentProtocol {
        document(objectId: objectId, mode: .handling)
    }
    
    func setDocument(
        objectId: String,
        mode: DocumentMode
    ) -> any SetDocumentProtocol {
        setDocument(objectId: objectId, mode: mode, inlineParameters: nil)
    }
    
    func setDocument(
        objectId: String,
        inlineParameters: EditorInlineSetObject?
    ) -> any SetDocumentProtocol {
        setDocument(objectId: objectId, mode: .handling, inlineParameters: inlineParameters)
    }
    
    func setDocument(
        objectId: String
    ) -> any SetDocumentProtocol {
        setDocument(objectId: objectId, mode: .handling, inlineParameters: nil)
    }
}

final class DocumentsProvider: DocumentsProviderProtocol {
    private var documentCache = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
    
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectLifecycleService)
    private var objectLifecycleService: any ObjectLifecycleServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    
    func document(objectId: String, mode: DocumentMode) -> any BaseDocumentProtocol {
        internalDocument(objectId: objectId, mode: mode)
    }
    
    func setDocument(
        objectId: String,
        mode: DocumentMode,
        inlineParameters: EditorInlineSetObject?
    ) -> any SetDocumentProtocol {
        let document = internalDocument(objectId: objectId, mode: mode)
        
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
    
    private func internalDocument(objectId: String, mode: DocumentMode) -> any BaseDocumentProtocol {
        if !mode.isHandling {
            let document = createBaseDocument(objectId: objectId, mode: mode)
            return document
        }
        
        if let value = documentCache.object(forKey: objectId as NSString) as? any BaseDocumentProtocol {
            return value
        }
        
        let document = createBaseDocument(objectId: objectId, mode: mode)
        documentCache.setObject(document, forKey: objectId as NSString)
        
        return document
    }
    
    private func createBaseDocument(objectId: String, mode: DocumentMode) -> some BaseDocumentProtocol {
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
            detailsStorage: detailsStorage
        )
        return BaseDocument(
            objectId: objectId,
            mode: mode,
            objectLifecycleService: objectLifecycleService,
            relationDetailsStorage: relationDetailsStorage, 
            objectTypeProvider: objectTypeProvider,
            accountParticipantsStorage: accountParticipantsStorage,
            eventsListener: eventsListener,
            viewModelSetter: viewModelSetter,
            infoContainer: infoContainer,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer,
            detailsStorage: detailsStorage
        )
    }
}
