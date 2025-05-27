import Foundation
import Services
import AnytypeCore

enum PropertiesInteractorError: Error {
    case documentRequired
}

protocol PropertiesInteractorProtocol: Sendable {
    func createProperty(spaceId: String, relation: RelationDetails) async throws -> RelationDetails
    func updateProperty(spaceId: String, relation: RelationDetails) async throws
    func addPropertyToType(relation: RelationDetails, isFeatured: Bool) async throws
    func addPropertyToDataview(objectId: String, relation: RelationDetails, activeViewId: String, typeDetails: ObjectDetails?) async throws
    func addPropertyToObject(objectId: String, relation: RelationDetails) async throws
}

final class PropertiesInteractor: PropertiesInteractorProtocol, Sendable {
    
    private let relationsService: any RelationsServiceProtocol = Container.shared.relationsService()
    private let dataviewService: any DataviewServiceProtocol = Container.shared.dataviewService()
    private let relationDetailsStorage: any RelationDetailsStorageProtocol = Container.shared.relationDetailsStorage()
    
    private let document: (any BaseDocumentProtocol)?
    
    init(objectId: String?, spaceId: String) {
        if let objectId = objectId, objectId.isNotEmpty {
            let documentsProvider = Container.shared.openedDocumentProvider()
            document = documentsProvider.document(objectId: objectId, spaceId: spaceId)
        } else {
            document = nil
        }
    }
    
    func createProperty(spaceId: String, relation: RelationDetails) async throws -> RelationDetails {
        try await relationsService.createRelation(spaceId: spaceId, relationDetails: relation)
    }
    
    func updateProperty(spaceId: String, relation: RelationDetails) async throws {
        try await relationsService.updateRelation(objectId: relation.id, fields: relation.fields)
    }
    
    func addPropertyToType(relation: RelationDetails, isFeatured: Bool) async throws {
        guard let document = document else { 
            throw PropertiesInteractorError.documentRequired 
        }
        guard let details = document.details else { return }
        
        if isFeatured {
            try await relationsService.addTypeFeaturedRecommendedRelation(details: details, relation: relation)
        } else {
            try await relationsService.addTypeRecommendedRelation(details: details, relation: relation)
        }
    }
    
    func addPropertyToDataview(objectId: String, relation: RelationDetails, activeViewId: String, typeDetails: ObjectDetails?) async throws {
        if let typeDetails {
            try await addPropertyToType(relation: relation, details: typeDetails)
        } else {
            try await dataviewService.addRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relationDetails: relation)
        }

        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relation: newOption.asMiddleware, viewId: activeViewId)
    }
    
    private func addPropertyToType(relation: RelationDetails, details: ObjectDetails) async throws {
        try await relationsService.addTypeRecommendedRelation(details: details, relation: relation)
    }
    
    func addPropertyToObject(objectId: String, relation: RelationDetails) async throws {
        try await relationsService.addRelations(objectId: objectId, relationsDetails: [relation])
    }
}
