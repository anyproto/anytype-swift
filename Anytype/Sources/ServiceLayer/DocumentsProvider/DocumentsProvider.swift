import Foundation
import Services

protocol DocumentsProviderProtocol {
    func document(
        objectId: String,
        spaceId: String,
        mode: DocumentMode
    ) -> any BaseDocumentProtocol
    
    func setDocument(
        objectId: String,
        spaceId: String,
        mode: DocumentMode,
        inlineParameters: EditorInlineSetObject?
    ) -> any SetDocumentProtocol
}

extension DocumentsProviderProtocol {
    func document(objectId: String, spaceId: String) -> any BaseDocumentProtocol {
        document(objectId: objectId, spaceId: spaceId, mode: .handling)
    }
    
    func setDocument(
        objectId: String,
        spaceId: String,
        mode: DocumentMode
    ) -> any SetDocumentProtocol {
        setDocument(objectId: objectId, spaceId: spaceId, mode: mode, inlineParameters: nil)
    }
    
    func setDocument(
        objectId: String,
        spaceId: String,
        inlineParameters: EditorInlineSetObject?
    ) -> any SetDocumentProtocol {
        setDocument(objectId: objectId, spaceId: spaceId, mode: .handling, inlineParameters: inlineParameters)
    }
    
    func setDocument(
        objectId: String,
        spaceId: String
    ) -> any SetDocumentProtocol {
        setDocument(objectId: objectId, spaceId: spaceId, mode: .handling, inlineParameters: nil)
    }
}

final class DocumentsProvider: DocumentsProviderProtocol {
    private var documentCache = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
    
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectLifecycleService)
    private var objectLifecycleService: any ObjectLifecycleServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: any AccountParticipantsStorageProtocol
    
    func document(objectId: String, spaceId: String, mode: DocumentMode) -> any BaseDocumentProtocol {
        internalDocument(objectId: objectId, spaceId: spaceId, mode: mode)
    }
    
    func setDocument(
        objectId: String,
        spaceId: String,
        mode: DocumentMode,
        inlineParameters: EditorInlineSetObject?
    ) -> any SetDocumentProtocol {
        let document = internalDocument(objectId: objectId, spaceId: spaceId, mode: mode)
        
        return SetDocument(
            document: document,
            inlineParameters: inlineParameters,
            propertyDetailsStorage: propertyDetailsStorage,
            objectTypeProvider: objectTypeProvider,
            accountParticipantsStorage: accountParticipantsStorage,
            permissionsBuilder: SetPermissionsBuilder()
        )
    }
    
    // MARK: - Private
    
    private func internalDocument(objectId: String, spaceId: String, mode: DocumentMode) -> any BaseDocumentProtocol {
        if !mode.isHandling {
            let document = createBaseDocument(objectId: objectId, spaceId: spaceId, mode: mode)
            return document
        }
        
        if let value = documentCache.object(forKey: objectId as NSString) as? any BaseDocumentProtocol {
            return value
        }
        
        let document = createBaseDocument(objectId: objectId, spaceId: spaceId, mode: mode)
        documentCache.setObject(document, forKey: objectId as NSString)
        
        return document
    }
    
    private func createBaseDocument(objectId: String, spaceId: String, mode: DocumentMode) -> some BaseDocumentProtocol {
        let infoContainer = InfoContainer()
        let restrictionsContainer = ObjectRestrictionsContainer()
        let detailsStorage = ObjectDetailsStorage()
        let viewModelSetter = DocumentViewModelSetter(
            detailsStorage: detailsStorage,
            restrictionsContainer: restrictionsContainer,
            infoContainer: infoContainer
        )
        let eventsListener = EventsListener(
            objectId: objectId,
            infoContainer: infoContainer,
            restrictionsContainer: restrictionsContainer,
            detailsStorage: detailsStorage
        )
        return BaseDocument(
            objectId: objectId,
            spaceId: spaceId,
            mode: mode,
            objectLifecycleService: objectLifecycleService,
            propertyDetailsStorage: propertyDetailsStorage, 
            objectTypeProvider: objectTypeProvider,
            accountParticipantsStorage: accountParticipantsStorage,
            eventsListener: eventsListener,
            viewModelSetter: viewModelSetter,
            infoContainer: infoContainer,
            restrictionsContainer: restrictionsContainer,
            detailsStorage: detailsStorage
        )
    }
}
