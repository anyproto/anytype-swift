import Foundation
import Services

protocol RelationsInteractorProtocol {
    func createRelation(spaceId: String, relation: RelationDetails) async throws -> RelationDetails
    func addRelationToObject(relation: RelationDetails) async throws
    func addRelationToDataview(objectId: String, relation: RelationDetails, activeViewId: String) async throws
}

final class RelationsInteractor: RelationsInteractorProtocol {
    
    private let objectId: String
    
    @Injected(\.relationsService)
    private var relationsService: RelationsServiceProtocol
    @Injected(\.dataviewService)
    private var dataviewService: DataviewServiceProtocol
    
    init(objectId: String) {
        self.objectId = objectId
    }
    
    func createRelation(spaceId: String, relation: RelationDetails) async throws -> RelationDetails {
        try await relationsService.createRelation(spaceId: spaceId, relationDetails: relation)
    }
    
    func addRelationToObject(relation: RelationDetails) async throws {
        try await relationsService.addRelations(objectId: objectId, relationsDetails: [relation])
    }
    
    func addRelationToDataview(objectId: String, relation: RelationDetails, activeViewId: String) async throws {
        try await dataviewService.addRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relationDetails: relation)
        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relation: newOption.asMiddleware, viewId: activeViewId)
    }
}
