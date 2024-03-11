import Foundation
import Services

final class RelationsSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let relationsInteractor: RelationsInteractorProtocol
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    
    init(
        searchService: SearchServiceProtocol,
        workspaceService: WorkspaceServiceProtocol,
        relationsInteractor: RelationsInteractorProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol
    ) {
        self.searchService = searchService
        self.workspaceService = workspaceService
        self.relationsInteractor = relationsInteractor
        self.relationDetailsStorage = relationDetailsStorage
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
