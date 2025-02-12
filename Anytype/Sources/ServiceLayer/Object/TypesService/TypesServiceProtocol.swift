import Services

enum TypesServiceError: Error {
    case deletingReadonlyType
}

protocol TypesServiceProtocol: Sendable {
    func createType(name: String, spaceId: String) async throws -> ObjectType
    func deleteType(typeId: String, spaceId: String) async throws
    
    func searchObjectTypes(
        text: String,
        includePins: Bool,
        includeLists: Bool,
        includeBookmarks: Bool,
        includeFiles: Bool,
        includeChat: Bool,
        includeTemplates: Bool,
        incudeNotForCreation: Bool,
        spaceId: String
    ) async throws -> [ObjectDetails]
    
    func searchListTypes(
        text: String,
        includePins: Bool,
        spaceId: String
    ) async throws -> [ObjectType]
    
    func searchLibraryObjectTypes(
        text: String,
        includeInstalledTypes: Bool,
        spaceId: String
    ) async throws -> [ObjectDetails]
    
    func searchPinnedTypes(
        text: String,
        spaceId: String
    ) async throws -> [ObjectType]
    
    func addPinedType(_ type: ObjectType, spaceId: String) throws
    func removePinedType(typeId: String, spaceId: String) throws
    func getPinnedTypes(spaceId: String) throws -> [ObjectType]
}
