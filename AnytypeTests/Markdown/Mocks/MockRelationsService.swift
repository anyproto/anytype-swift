import Foundation
import Services
import ProtobufMessages
import SwiftProtobuf

class MockRelationsService: RelationsServiceProtocol {
    // Last call data storage
    var lastAddFeaturedRelation: (objectId: String, relationKey: String)?
    var lastRemoveFeaturedRelation: (objectId: String, relationKey: String)?
    var lastUpdateRelation: (objectId: String, relationKey: String, value: Google_Protobuf_Value)?
    var lastUpdateRelationOption: (id: String, text: String, color: String?)?
    var lastCreateRelation: (spaceId: String, relationDetails: RelationDetails)?
    var lastAddRelations: (objectId: String, relations: Any)?
    var lastRemoveRelation: (objectId: String, relationKey: String)?
    var lastRemoveRelations: (objectId: String, relationKeys: [String])?
    var lastAddRelationOption: (spaceId: String, relationKey: String, optionText: String, color: String?)?
    var lastRemoveRelationOptions: [String]?
    
    // Type relations last call data
    var lastUpdateTypeRelations: (typeId: String, recommendedRelationIds: [ObjectId], recommendedFeaturedRelationsIds: [ObjectId])?
    var lastUpdateRecommendedRelations: (typeId: String, relationIds: [ObjectId])?
    var lastUpdateFeaturedRelations: [ObjectId]?

    // Configurable async result handlers (optional error throwing)
    var addFeaturedRelationError: (any Error)?
    var removeFeaturedRelationError: (any Error)?
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
    var updateFeaturedRelationsError: (any Error)?

    func addFeaturedRelation(objectId: String, relationKey: String) async throws {
        lastAddFeaturedRelation = (objectId, relationKey)
        if let error = addFeaturedRelationError {
            throw error
        }
    }
    
    func removeFeaturedRelation(objectId: String, relationKey: String) async throws {
        lastRemoveFeaturedRelation = (objectId, relationKey)
        if let error = removeFeaturedRelationError {
            throw error
        }
    }
    
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
    
    func updateTypeRelations(typeId: String, recommendedRelationIds: [ObjectId], recommendedFeaturedRelationsIds: [ObjectId]) async throws {
        lastUpdateTypeRelations = (typeId, recommendedRelationIds, recommendedFeaturedRelationsIds)
        if let error = updateTypeRelationsError {
            throw error
        }
    }
    
    func updateRecommendedRelations(typeId: String, relationIds: [ObjectId]) async throws {
        lastUpdateRecommendedRelations = (typeId, relationIds)
        if let error = updateRecommendedRelationsError {
            throw error
        }
    }
    
    func updateRecommendedFeaturedRelations(typeId: String, relationIds: [ObjectId]) async throws {
        lastUpdateFeaturedRelations = relationIds
        if let error = updateFeaturedRelationsError {
            throw error
        }
    }

    // Convenience method to reset all last call data
    func reset() {
        lastAddFeaturedRelation = nil
        lastRemoveFeaturedRelation = nil
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
        lastUpdateFeaturedRelations = nil
    }
}