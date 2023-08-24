import Services

protocol SetTemplatesInteractorProtocol {
    func isTemplatesAvailableFor(setDocument: SetDocumentProtocol, setObject: ObjectDetails) async throws -> Bool
}

final class SetTemplatesInteractor: SetTemplatesInteractorProtocol {
    private let templatesService: TemplatesServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(templatesService: TemplatesServiceProtocol, objectTypeProvider: ObjectTypeProviderProtocol) {
        self.templatesService = templatesService
        self.objectTypeProvider = objectTypeProvider
    }
    
    func isTemplatesAvailableFor(setDocument: SetDocumentProtocol, setObject: ObjectDetails) async throws -> Bool {
        if setDocument.isRelationsSet() {
            return true
        }
        
        if setDocument.isCollection() {
            return objectTypeProvider.defaultObjectType(spaceId: setDocument.spaceId)?.recommendedLayout?.isTemplatesAvailable ?? false
        }
        
        guard setObject.setOf.count == 1,
                let typeId = setObject.setOf.first else {
            return false
        }
        
        let objectDetails = try await templatesService.objectDetails(objectId: typeId)
        
        return objectDetails.setIsTemplatesAvailable
    }
}
