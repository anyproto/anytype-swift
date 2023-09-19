import Services

protocol SetTemplatesInteractorProtocol {
    func isTemplatesAvailableFor(setObject: ObjectDetails) async throws -> Bool
    func isTemplatesAvailableForActiveView(setDocument: SetDocumentProtocol) async throws -> Bool
}

final class SetTemplatesInteractor: SetTemplatesInteractorProtocol {
    private let templatesService: TemplatesServiceProtocol
    private let objecTypeProvider: ObjectTypeProviderProtocol
    
    init(templatesService: TemplatesServiceProtocol, objecTypeProvider: ObjectTypeProviderProtocol) {
        self.templatesService = templatesService
        self.objecTypeProvider = objecTypeProvider
    }
    
    func isTemplatesAvailableFor(setObject: ObjectDetails) async throws -> Bool {
        guard setObject.setOf.count == 1, let objectTypeId = setObject.setOf.first, objectTypeId.isNotEmpty else {
            return false
        }
        let objectType = try objecTypeProvider.objectType(id: objectTypeId)
        return objectType.setIsTemplatesAvailable
    }
    
    func isTemplatesAvailableForActiveView(setDocument: SetDocumentProtocol) async throws -> Bool {
        let objectType = try setDocument.defaultObjectTypeForActiveView()
        return objectType.setIsTemplatesAvailable
    }
}

