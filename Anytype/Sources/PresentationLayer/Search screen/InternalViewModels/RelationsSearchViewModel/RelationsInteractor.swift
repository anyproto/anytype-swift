import Foundation
import Services

protocol RelationsInteractorProtocol: Sendable {
    func createRelation(spaceId: String, relation: RelationDetails) async throws -> RelationDetails
    func updateRelation(spaceId: String, relation: RelationDetails) async throws
    func addRelationToType(relation: RelationDetails, isFeatured: Bool) async throws
    func addRelationToDataview(objectId: String, relation: RelationDetails, activeViewId: String) async throws
}

final class RelationsInteractor: RelationsInteractorProtocol, Sendable {
    
    private let relationsService: any RelationsServiceProtocol = Container.shared.relationsService()
    private let dataviewService: any DataviewServiceProtocol = Container.shared.dataviewService()
    
    private let document: any BaseDocumentProtocol
    
    init(objectId: String, spaceId: String) {
        let documentsProvider = Container.shared.openedDocumentProvider()
        document = documentsProvider.document(objectId: objectId, spaceId: spaceId)
    }
    
    func createRelation(spaceId: String, relation: RelationDetails) async throws -> RelationDetails {
        try await relationsService.createRelation(spaceId: spaceId, relationDetails: relation)
    }
    
    func updateRelation(spaceId: String, relation: RelationDetails) async throws {
        try await relationsService.updateRelation(objectId: relation.id, fields: relation.fields)
    }
    
    func addRelationToType(relation: RelationDetails, isFeatured: Bool) async throws {
        guard let details = document.details else { return }
        
        if isFeatured {
            var relationIds = details.recommendedFeaturedRelations
            relationIds.insert(relation.id, at: 0)
            try await relationsService.updateRecommendedFeaturedRelations(typeId: document.objectId, relationIds: relationIds)
        } else {
            var relationIds = details.recommendedRelations
            relationIds.insert(relation.id, at: 0)
            try await self.relationsService.updateRecommendedRelations(typeId: document.objectId, relationIds: relationIds)
        }
    }
    
    func addRelationToDataview(objectId: String, relation: RelationDetails, activeViewId: String) async throws {
        try await dataviewService.addRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relationDetails: relation)
        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relation: newOption.asMiddleware, viewId: activeViewId)
    }
}
