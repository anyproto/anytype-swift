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
    
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
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
            var recommendedFeaturedRelationsDetails = details.recommendedFeaturedRelationsDetails
            recommendedFeaturedRelationsDetails.insert(relation, at: 0)
            try await relationsService.updateTypeRelations(
                typeId: document.objectId,
                recommendedRelations: details.recommendedRelationsDetails,
                recommendedFeaturedRelations: recommendedFeaturedRelationsDetails,
                recommendedHiddenRelations: details.recommendedHiddenRelationsDetails
            )
        } else {
            var recommendedRelationsDetails = details.recommendedRelationsDetails
            recommendedRelationsDetails.insert(relation, at: 0)
            try await relationsService.updateTypeRelations(
                typeId: document.objectId,
                recommendedRelations: recommendedRelationsDetails,
                recommendedFeaturedRelations: details.recommendedFeaturedRelationsDetails,
                recommendedHiddenRelations: details.recommendedHiddenRelationsDetails
            )
        }
    }
    
    func addRelationToDataview(objectId: String, relation: RelationDetails, activeViewId: String) async throws {
        try await dataviewService.addRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relationDetails: relation)
        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relation: newOption.asMiddleware, viewId: activeViewId)
    }
}
