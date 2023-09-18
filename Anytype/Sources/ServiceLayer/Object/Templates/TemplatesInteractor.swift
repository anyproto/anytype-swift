import Services

protocol SetTemplatesInteractorProtocol {
    func isTemplatesAvailableFor(setObject: ObjectDetails) async throws -> Bool
    func isTemplatesAvailableForActiveView(setDocument: SetDocumentProtocol) async throws -> Bool
    func isTemplatesAvailableFor(activeView: DataviewView) async throws -> Bool
    func objectDetails(for objectTypeId: String) async throws -> ObjectDetails
}

final class SetTemplatesInteractor: SetTemplatesInteractorProtocol {
    private let templatesService: TemplatesServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(templatesService: TemplatesServiceProtocol, objectTypeProvider: ObjectTypeProviderProtocol) {
        self.templatesService = templatesService
        self.objectTypeProvider = objectTypeProvider
    }
    
    func isTemplatesAvailableFor(setObject: ObjectDetails) async throws -> Bool {
        guard setObject.setOf.count == 1, let objectTypeId = setObject.setOf.first, objectTypeId.isNotEmpty else {
            return false
        }
        return try await isTemplatesAvailableFor(objectTypeId: objectTypeId)
    }
    
    func isTemplatesAvailableForActiveView(setDocument: SetDocumentProtocol) async throws -> Bool {
        let objectTypeId = setDocument.defaultObjectTypeForActiveView()?.id ?? ""
        return try await isTemplatesAvailableFor(objectTypeId: objectTypeId)
    }
    
    func objectDetails(for objectTypeId: String) async throws -> ObjectDetails {
        try await templatesService.objectDetails(objectId: objectTypeId)
    }
    
    private func isTemplatesAvailableFor(objectTypeId: String) async throws -> Bool {
        let objectDetails = try await objectDetails(for: objectTypeId)
        return objectDetails.setIsTemplatesAvailable
    }
}
