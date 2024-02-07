import Services
import AnytypeCore


final class ObjectTypeSearchInteractor {
    private let spaceId: String
    private let workspaceService: WorkspaceServiceProtocol
    private let typesService: TypesServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(
        spaceId: String,
        workspaceService: WorkspaceServiceProtocol,
        typesService: TypesServiceProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.spaceId = spaceId
        self.workspaceService = workspaceService
        self.typesService = typesService
        self.objectTypeProvider = objectTypeProvider
    }
    
    // MARK: - Search
    func searchObjectTypes(text: String, includePins: Bool) async throws -> [ObjectType] {
        return try await typesService.searchObjectTypes(
            text: text, 
            includePins: includePins,
            includeLists: false,
            includeBookmark: true,
            spaceId: spaceId
        ).map { ObjectType(details: $0) }
    }
    
    func searchListTypes(text: String, includePins: Bool) async throws -> [ObjectType] {
        return try await typesService.searchListTypes(
            text: text, includePins: includePins, spaceId: spaceId
        )
    }
    
    func searchLibraryTypes(text: String) async throws -> [ObjectType] {
        let installedObjectIds = objectTypeProvider.objectTypes(spaceId: spaceId).map(\.sourceObject)
        
        return try await typesService.searchLibraryObjectTypes(
            text: text, excludedIds: installedObjectIds
        ).map { ObjectType(details: $0) }
    }
    
    func searchPinnedTypes(text: String) async throws -> [ObjectType] {
        return try await typesService.searchPinnedTypes(text: text, spaceId: spaceId)
    }
    
    // MARK: - Working with types
    func installType(objectId: String) async throws {
        _ = try await workspaceService.installObject(spaceId: spaceId, objectId: objectId)
    }
    
    func createNewType(name: String) async throws -> ObjectType {
        return try await typesService.createType(name: name, spaceId: spaceId)
    }
    
    func defaultObjectType() throws -> ObjectType {
        return try objectTypeProvider.defaultObjectType(spaceId: spaceId)
    }
}
