import Services
import AnytypeCore


final class ObjectTypeSearchInteractor {
    private let spaceId: String
    private let searchService: SearchServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let typesService: TypesServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(
        spaceId: String,
        searchService: SearchServiceProtocol,
        workspaceService: WorkspaceServiceProtocol,
        typesService: TypesServiceProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.spaceId = spaceId
        self.searchService = searchService
        self.workspaceService = workspaceService
        self.typesService = typesService
        self.objectTypeProvider = objectTypeProvider
    }
    
    // MARK: - Search
    func searchObjectTypes(text: String) async -> [ObjectType] {
        guard let details = try? await searchService.searchObjectTypes(
            text: text,
            filteringTypeId: nil,
            shouldIncludeSets: false,
            shouldIncludeCollections: false,
            shouldIncludeBookmark: true,
            spaceId: spaceId
        ) else {
            return []
        }

        return details.map { ObjectType(details: $0) }
    }
    
    func searchListTypes(text: String) async -> [ObjectType] {
        guard let details = try? await searchService.searchListTypes(
            text: text, spaceId: spaceId
        ) else {
            return []
        }
        
        return details.map { ObjectType(details: $0) }
    }
    
    func searchLibraryTypes(text: String) async -> [ObjectType] {
        let installedObjectIds = objectTypeProvider.objectTypes(spaceId: spaceId).map(\.sourceObject)
        
        guard let details = try? await searchService.searchLibraryObjectTypes(
            text: text, excludedIds: installedObjectIds
        ) else {
            return []
        }
        
        return details.map { ObjectType(details: $0) }
    }
    
    // MARK: - Working with types
    func installType(objectId: String) async throws {
        _ = try await workspaceService.installObject(spaceId: spaceId, objectId: objectId)
    }
    
    func createNewType(name: String) async throws -> ObjectType {
        let details = try await typesService.createType(name: name, spaceId: spaceId)
        return ObjectType(details: details)
    }
}
