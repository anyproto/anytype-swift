import Foundation
import Services

final class RelationsSearchInteractor {
    
    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: RelationDetailsStorageProtocol
    
    private let relationsInteractor: RelationsInteractorProtocol
    
    init(relationsInteractor: RelationsInteractorProtocol) {
        self.relationsInteractor = relationsInteractor
    }
    
    func search(text: String, excludedIds: [String], spaceId: String) async throws -> [RelationDetails] {
        try await searchService.searchRelations(text: text, excludedIds: excludedIds, spaceId: spaceId)
    }
    
    func searchInLibrary(text: String, spaceId: String) async throws -> [RelationDetails] {
        let excludedIds = relationDetailsStorage.relationsDetails(spaceId: spaceId).map(\.sourceObject)
        return try await searchService.searchLibraryRelations(text: text, excludedIds: excludedIds)
    }
    
    func installRelation(spaceId: String, objectId: String) async throws -> RelationDetails? {
        let objectDetails = try await workspaceService.installObject(spaceId: spaceId, objectId: objectId)
        return RelationDetails(objectDetails: objectDetails)
    }
    
    func addRelationToObject(relation: RelationDetails) async throws {
        try await relationsInteractor.addRelationToObject(relation: relation)
    }
    
    func addRelationToDataview(objectId: String, relation: RelationDetails, activeViewId: String) async throws {
        try await relationsInteractor.addRelationToDataview(objectId: objectId, relation: relation, activeViewId: activeViewId)
    }
}
