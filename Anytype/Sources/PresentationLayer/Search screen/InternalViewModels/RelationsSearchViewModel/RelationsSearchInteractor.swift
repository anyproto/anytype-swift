import Foundation
import BlocksModels

final class RelationsSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let relationsService: RelationsServiceProtocol
    
    init(
        searchService: SearchServiceProtocol,
        workspaceService: WorkspaceServiceProtocol,
        relationsService: RelationsServiceProtocol
    ) {
        self.searchService = searchService
        self.workspaceService = workspaceService
        self.relationsService = relationsService
    }
    
    func search(text: String, excludedIds: [String]) -> [RelationDetails] {
        return searchService.searchRelations(text: text, excludedIds: excludedIds) ?? []
    }
    
    func searchInMarketplace(text: String) -> [RelationDetails] {
        return searchService.searchMarketplaceRelations(text: text, includeInstalled: false) ?? []
    }
    
    func installRelation(objectId: String) -> RelationDetails? {
        return workspaceService.installObject(objectId: objectId)
            .map { RelationDetails(objectDetails: $0) }
    }
    
    func addRelationToObject(relation: RelationDetails) -> Bool {
        return relationsService.addRelations(relationsDetails: [relation])
    }
}
