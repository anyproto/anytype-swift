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
    
    func searchInMarketplace(text: String, excludedIds: [String]) -> [RelationDetails] {
        return searchService.searchMarketplaceRelations(text: text, excludedIds: excludedIds) ?? []
    }
    
    func installRelations(objectIds: [String]) -> [RelationDetails] {
        return objectIds
            .compactMap { workspaceService.installObject(objectId: $0) }
            .map { RelationDetails(objectDetails: $0)}
    }
    
    func addRelationToObject(relations: [RelationDetails]) {
        relationsService.addRelations(relationsDetails: relations)
    }
}
