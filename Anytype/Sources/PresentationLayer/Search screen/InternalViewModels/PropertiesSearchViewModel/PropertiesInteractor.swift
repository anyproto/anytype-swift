import Foundation
import Services
import AnytypeCore


protocol PropertiesInteractorProtocol: Sendable {
    func createRelation(spaceId: String, relation: RelationDetails) async throws -> RelationDetails
    func updateRelation(spaceId: String, relation: RelationDetails) async throws
    func addRelationToType(relation: RelationDetails, isFeatured: Bool) async throws
    func addRelationToDataview(objectId: String, relation: RelationDetails, activeViewId: String, typeDetails: ObjectDetails?) async throws
    func addRelationToObject(objectId: String, relation: RelationDetails) async throws
}

final class PropertiesInteractor: PropertiesInteractorProtocol, Sendable {
    
    private let relationsService: any RelationsServiceProtocol = Container.shared.relationsService()
    private let dataviewService: any DataviewServiceProtocol = Container.shared.dataviewService()
    private let relationDetailsStorage: any RelationDetailsStorageProtocol = Container.shared.relationDetailsStorage()
    
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
            try await relationsService.addTypeFeaturedRecommendedRelation(details: details, relation: relation)
        } else {
            try await relationsService.addTypeRecommendedRelation(details: details, relation: relation)
        }
    }
    
    func addRelationToDataview(objectId: String, relation: RelationDetails, activeViewId: String, typeDetails: ObjectDetails?) async throws {
        if let typeDetails {
            try await addRelationToType(relation: relation, details: typeDetails)
        } else {
            try await dataviewService.addRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relationDetails: relation)
        }

        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relation: newOption.asMiddleware, viewId: activeViewId)
    }
    
    private func addRelationToType(relation: RelationDetails, details: ObjectDetails) async throws {
        try await relationsService.addTypeRecommendedRelation(details: details, relation: relation)
    }
    
    func addRelationToObject(objectId: String, relation: RelationDetails) async throws {
        try await relationsService.addRelations(objectId: objectId, relationsDetails: [relation])
    }
}
