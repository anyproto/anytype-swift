import Services

enum TypesServiceError: Error {
    case deletingReadonlyType
}

protocol TypesServiceProtocol {
    func createType(name: String, spaceId: String) async throws -> ObjectType
    func deleteType(_ type: ObjectType, spaceId: String) async throws
    
    func searchObjectTypes(
        text: String,
        includePins: Bool,
        includeLists: Bool,
        includeBookmark: Bool,
        spaceId: String
    ) async throws -> [ObjectDetails]
    
    func searchListTypes(
        text: String,
        includePins: Bool,
        spaceId: String
    ) async throws -> [ObjectType]
    
    func searchLibraryObjectTypes(
        text: String,
        excludedIds: [String]
    ) async throws -> [ObjectDetails]
    
    func searchPinnedTypes(
        text: String,
        spaceId: String
    ) async throws -> [ObjectType]
    
    func addPinedType(_ type: ObjectType, spaceId: String) throws
    func removePinedType(_ type: ObjectType, spaceId: String) throws
}
