import Services

protocol SetTemplatesInteractorProtocol {
    func isTemplatesAvailableFor(setDocument: SetDocumentProtocol, setObject: ObjectDetails) async throws -> Bool
}

final class SetTemplatesInteractor: SetTemplatesInteractorProtocol {
    private let templatesService: TemplatesServiceProtocol
    
    init(templatesService: TemplatesServiceProtocol) {
        self.templatesService = templatesService
    }
    
    func isTemplatesAvailableFor(setDocument: SetDocumentProtocol, setObject: ObjectDetails) async throws -> Bool {
        if setDocument.isRelationsSet() {
            return true
        }
        
        guard setObject.setOf.count == 1,
                let typeId = setObject.setOf.first else {
            return false
        }
        
        let objectDetails = try await templatesService.typeObjectDetails(objectTypeId: typeId)
        
        return objectDetails.setIsTemplatesAvailable
    }
}
