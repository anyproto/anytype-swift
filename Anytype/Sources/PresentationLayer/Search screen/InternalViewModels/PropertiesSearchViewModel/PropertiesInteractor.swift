import Foundation
import Services
import AnytypeCore

enum PropertiesInteractorError: Error {
    case documentRequired
}

protocol PropertiesInteractorProtocol: Sendable {
    func createProperty(spaceId: String, relation: PropertyDetails) async throws -> PropertyDetails
    func updateProperty(spaceId: String, relation: PropertyDetails) async throws
    func addPropertyToType(relation: PropertyDetails, isFeatured: Bool) async throws
    func addPropertyToDataview(objectId: String, relation: PropertyDetails, activeViewId: String, typeDetails: ObjectDetails?) async throws
    func addPropertyToObject(objectId: String, relation: PropertyDetails) async throws
}

final class PropertiesInteractor: PropertiesInteractorProtocol, Sendable {
    
    private let propertiesService: any PropertiesServiceProtocol = Container.shared.propertiesService()
    private let dataviewService: any DataviewServiceProtocol = Container.shared.dataviewService()
    private let propertyDetailsStorage: any PropertyDetailsStorageProtocol = Container.shared.propertyDetailsStorage()
    
    private let document: (any BaseDocumentProtocol)?
    
    init(objectId: String?, spaceId: String) {
        if let objectId = objectId, objectId.isNotEmpty {
            let documentsProvider = Container.shared.openedDocumentProvider()
            document = documentsProvider.document(objectId: objectId, spaceId: spaceId)
        } else {
            document = nil
        }
    }
    
    func createProperty(spaceId: String, relation: PropertyDetails) async throws -> PropertyDetails {
        try await propertiesService.createProperty(spaceId: spaceId, propertyDetails: relation)
    }
    
    func updateProperty(spaceId: String, relation: PropertyDetails) async throws {
        try await propertiesService.updateProperty(objectId: relation.id, fields: relation.fields)
    }
    
    func addPropertyToType(relation: PropertyDetails, isFeatured: Bool) async throws {
        guard let document = document else { 
            throw PropertiesInteractorError.documentRequired 
        }
        guard let details = document.details else { return }
        
        if isFeatured {
            try await propertiesService.addTypeFeaturedRecommendedProperty(details: details, property: relation)
        } else {
            try await propertiesService.addTypeRecommendedProperty(details: details, property: relation)
        }
    }
    
    func addPropertyToDataview(objectId: String, relation: PropertyDetails, activeViewId: String, typeDetails: ObjectDetails?) async throws {
        if let typeDetails {
            try await addPropertyToType(relation: relation, details: typeDetails)
        } else {
            try await dataviewService.addRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relationDetails: relation)
        }

        let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
        try await dataviewService.addViewRelation(objectId: objectId, blockId: SetConstants.dataviewBlockId, relation: newOption.asMiddleware, viewId: activeViewId)
    }
    
    private func addPropertyToType(relation: PropertyDetails, details: ObjectDetails) async throws {
        try await propertiesService.addTypeRecommendedProperty(details: details, property: relation)
    }
    
    func addPropertyToObject(objectId: String, relation: PropertyDetails) async throws {
        try await propertiesService.addProperties(objectId: objectId, propertiesDetails: [relation])
    }
}
