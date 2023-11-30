import Foundation
import Services

protocol RelationsInteractorProtocol {
    func createRelation(spaceId: String, relation: RelationDetails) async throws -> RelationDetails
    func addRelationToObject(relation: RelationDetails) async throws
    func addRelationToDataview(relation: RelationDetails, activeViewId: String) async throws
}

final class RelationsInteractor: RelationsInteractorProtocol {
    
    private let relationsService: RelationsServiceProtocol
    private let dataviewService: DataviewServiceProtocol
    
    init(
        relationsService: RelationsServiceProtocol,
        dataviewService: DataviewServiceProtocol
    ) {
        self.relationsService = relationsService
        self.dataviewService = dataviewService
    }
    
    func createRelation(spaceId: String, relation: RelationDetails) async throws -> RelationDetails {
        try await relationsService.createRelation(spaceId: spaceId, relationDetails: relation)
    }
    
    func addRelationToObject(relation: RelationDetails) async throws {
        try await relationsService.addRelations(relationsDetails: [relation])
    }
    
    func addRelationToDataview(relation: RelationDetails, activeViewId: String) async throws {
        try await dataviewService.addRelation(relation)
        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(newOption.asMiddleware, viewId: activeViewId)
    }
}
