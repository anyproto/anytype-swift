public protocol TypesServiceProtocol {
    func createType(name: String, spaceId: String) async throws -> ObjectDetails
    
    func searchObjectTypes(
        text: String,
        filteringTypeId: String?,
        shouldIncludeLists: Bool,
        shouldIncludeBookmark: Bool,
        spaceId: String
    ) async throws -> [ObjectDetails]
    
    func searchListTypes(text: String, spaceId: String) async throws -> [ObjectDetails]
    
    func searchLibraryObjectTypes(
        text: String,
        excludedIds: [String]
    ) async throws -> [ObjectDetails]
}
