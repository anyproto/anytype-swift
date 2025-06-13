import Foundation
import Services
import ProtobufMessages
import SwiftProtobuf

class MockPropertiesService: PropertiesServiceProtocol {
    // Last call data storage
    var lastUpdateRelation: (objectId: String, relationKey: String, value: Google_Protobuf_Value)?
    var lastUpdateRelationOption: (id: String, text: String, color: String?)?
    var lastCreateRelation: (spaceId: String, relationDetails: RelationDetails)?
    var lastAddRelations: (objectId: String, relations: Any)?
    var lastRemoveRelation: (objectId: String, relationKey: String)?
    var lastRemoveRelations: (objectId: String, relationKeys: [String])?
    var lastAddRelationOption: (spaceId: String, relationKey: String, optionText: String, color: String?)?
    var lastRemoveRelationOptions: [String]?
    
    // Type relations last call data
    var lastUpdateTypeRelations: (typeId: String, recommendedRelations: [RelationDetails], recommendedFeaturedRelations: [RelationDetails], recommendedHiddenRelations: [RelationDetails])?
    var lastUpdateRecommendedRelations: (typeId: String, relations: [RelationDetails])?
    var lastUpdateRecommendedFeaturedRelations: (typeId: String, relations: [RelationDetails])?
    var lastUpdateRecommendedHiddenRelations: (typeId: String, relations: [RelationDetails])?
    var lastSetFeaturedRelation: (objectId: String, featuredRelationIds: [String])?
    var lastToggleDescription: (objectId: String, isOn: Bool)?

    // Configurable async result handlers (optional error throwing)
    var updateRelationError: (any Error)?
    var updateRelationOptionError: (any Error)?
    var createRelationError: (any Error)?
    var addRelationsError: (any Error)?
    var removeRelationError: (any Error)?
    var removeRelationsError: (any Error)?
    var addRelationOptionError: (any Error)?
    var removeRelationOptionsError: (any Error)?
    var updateTypeRelationsError: (any Error)?
    var updateRecommendedRelationsError: (any Error)?
    var updateRecommendedFeaturedRelationsError: (any Error)?
    var updateRecommendedHiddenRelationsError: (any Error)?
    var setFeaturedRelationError: (any Error)?
    var toggleDescriptionError: (any Error)?
    
    func updateRelation(objectId: String, relationKey: String, value: Google_Protobuf_Value) async throws {
        lastUpdateRelation = (objectId, relationKey, value)
        if let error = updateRelationError {
            throw error
        }
    }
    
    func updateRelationOption(id: String, text: String, color: String?) async throws {
        lastUpdateRelationOption = (id, text, color)
        if let error = updateRelationOptionError {
            throw error
        }
    }
    
    func updateRelation(objectId: String, fields: [String: Google_Protobuf_Value]) async throws {
        // Implementation needed
    }
    
    func createRelation(spaceId: String, relationDetails: RelationDetails) async throws -> RelationDetails {
        lastCreateRelation = (spaceId, relationDetails)
        if let error = createRelationError {
            throw error
        }
        return relationDetails
    }
    
    func addRelations(objectId: String, relationsDetails: [RelationDetails]) async throws {
        lastAddRelations = (objectId, relationsDetails)
        if let error = addRelationsError {
            throw error
        }
    }
    
    func addRelations(objectId: String, relationKeys: [String]) async throws {
        lastAddRelations = (objectId, relationKeys)
        if let error = addRelationsError {
            throw error
        }
    }
    
    func removeRelation(objectId: String, relationKey: String) async throws {
        lastRemoveRelation = (objectId, relationKey)
        if let error = removeRelationError {
            throw error
        }
    }
    
    func removeRelations(objectId: String, relationKeys: [String]) async throws {
        lastRemoveRelations = (objectId, relationKeys)
        if let error = removeRelationsError {
            throw error
        }
    }
    
    func addRelationOption(spaceId: String, relationKey: String, optionText: String, color: String?) async throws -> String? {
        lastAddRelationOption = (spaceId, relationKey, optionText, color)
        if let error = addRelationOptionError {
            throw error
        }
        return nil
    }
    
    func removeRelationOptions(ids: [String]) async throws {
        lastRemoveRelationOptions = ids
        if let error = removeRelationOptionsError {
            throw error
        }
    }
    
    func updateTypeRelations(
        typeId: String,
        recommendedRelations: [RelationDetails],
        recommendedFeaturedRelations: [RelationDetails],
        recommendedHiddenRelations: [RelationDetails]
    ) async throws {
        lastUpdateTypeRelations = (typeId, recommendedRelations, recommendedFeaturedRelations, recommendedHiddenRelations)
        if let error = updateTypeRelationsError {
            throw error
        }
    }
    
    func updateRecommendedRelations(typeId: String, relations: [RelationDetails]) async throws {
        lastUpdateRecommendedRelations = (typeId, relations)
        if let error = updateRecommendedRelationsError {
            throw error
        }
    }
    
    func updateRecommendedFeaturedRelations(typeId: String, relations: [RelationDetails]) async throws {
        lastUpdateRecommendedFeaturedRelations = (typeId, relations)
        if let error = updateRecommendedFeaturedRelationsError {
            throw error
        }
    }
    
    func updateRecommendedHiddenRelations(typeId: String, relations: [RelationDetails]) async throws {
        lastUpdateRecommendedHiddenRelations = (typeId, relations)
        if let error = updateRecommendedHiddenRelationsError {
            throw error
        }
    }
    
    func getConflictRelationsForType(typeId: String, spaceId: String) async throws -> [String] {
        return []
    }
    
    func setFeaturedRelation(objectId: String, featuredRelationIds: [String]) async throws {
        lastSetFeaturedRelation = (objectId, featuredRelationIds)
        if let error = setFeaturedRelationError {
            throw error
        }
    }
    
    func toggleDescription(objectId: String, isOn: Bool) async throws {
        lastToggleDescription = (objectId, isOn)
        if let error = toggleDescriptionError {
            throw error
        }
    }
    
    func updateTypeRelations(typeId: String, dataviewId: String, recommendedRelations: [Services.RelationDetails], recommendedFeaturedRelations: [Services.RelationDetails], recommendedHiddenRelations: [Services.RelationDetails]) async throws {
        fatalError()
    }

    // Convenience method to reset all last call data
    func reset() {
        lastUpdateRelation = nil
        lastUpdateRelationOption = nil
        lastCreateRelation = nil
        lastAddRelations = nil
        lastRemoveRelation = nil
        lastRemoveRelations = nil
        lastAddRelationOption = nil
        lastRemoveRelationOptions = nil
        lastUpdateTypeRelations = nil
        lastUpdateRecommendedRelations = nil
        lastUpdateRecommendedFeaturedRelations = nil
        lastUpdateRecommendedHiddenRelations = nil
        lastSetFeaturedRelation = nil
        lastToggleDescription = nil
    }
}
