import Foundation
import Services

final class RelationsSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let relationsService: RelationsServiceProtocol
    private let dataviewService: DataviewServiceProtocol
    
    init(
        searchService: SearchServiceProtocol,
        workspaceService: WorkspaceServiceProtocol,
        relationsService: RelationsServiceProtocol,
        dataviewService: DataviewServiceProtocol
    ) {
        self.searchService = searchService
        self.workspaceService = workspaceService
        self.relationsService = relationsService
        self.dataviewService = dataviewService
    }
    
    func search(text: String, excludedIds: [String]) async throws -> [RelationDetails] {
        try await searchService.searchRelations(text: text, excludedIds: excludedIds)
    }
    
    func searchInMarketplace(text: String) async throws -> [RelationDetails] {
        try await searchService.searchMarketplaceRelations(text: text, includeInstalled: false)
    }
    
    func installRelation(objectId: String) -> RelationDetails? {
        return workspaceService.installObject(objectId: objectId)
            .map { RelationDetails(objectDetails: $0) }
    }
    
    func addRelationToObject(relation: RelationDetails) -> Bool {
        return relationsService.addRelations(relationsDetails: [relation])
    }
    
    func addRelationToDataview(relation: RelationDetails, activeViewId: String) async throws {
        try await dataviewService.addRelation(relation)
        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(newOption.asMiddleware, viewId: activeViewId)
    }
}
