import Foundation
import Services
import ProtobufMessages
import SwiftProtobuf

class MockPropertiesService: PropertiesServiceProtocol {
    // Last call data storage
    var lastUpdateProperty: (objectId: String, propertyKey: String, value: Google_Protobuf_Value)?
    var lastUpdatePropertyOption: (id: String, text: String, color: String?)?
    var lastCreateProperty: (spaceId: String, propertyDetails: PropertyDetails)?
    var lastAddProperties: (objectId: String, properties: Any)?
    var lastRemoveProperty: (objectId: String, propertyKey: String)?
    var lastRemoveProperties: (objectId: String, propertyKeys: [String])?
    var lastAddPropertyOption: (spaceId: String, propertyKey: String, optionText: String, color: String?)?
    var lastRemovePropertyOptions: [String]?
    
    // Type properties last call data
    var lastUpdateTypeProperties: (typeId: String, dataviewId: String, recommendedProperties: [PropertyDetails], recommendedFeaturedProperties: [PropertyDetails], recommendedHiddenProperties: [PropertyDetails])?
    var lastGetConflictPropertiesForType: (typeId: String, spaceId: String)?
    var lastSetFeaturedProperty: (objectId: String, featuredPropertyIds: [String])?
    var lastToggleDescription: (objectId: String, isOn: Bool)?

    // Configurable async result handlers (optional error throwing)
    var updatePropertyError: (any Error)?
    var updatePropertyOptionError: (any Error)?
    var createPropertyError: (any Error)?
    var addPropertiesError: (any Error)?
    var removePropertyError: (any Error)?
    var removePropertiesError: (any Error)?
    var addPropertyOptionError: (any Error)?
    var removePropertyOptionsError: (any Error)?
    var updateTypePropertiesError: (any Error)?
    var getConflictPropertiesForTypeError: (any Error)?
    var setFeaturedPropertyError: (any Error)?
    var toggleDescriptionError: (any Error)?
    
    func updateProperty(objectId: String, propertyKey: String, value: Google_Protobuf_Value) async throws {
        lastUpdateProperty = (objectId, propertyKey, value)
        if let error = updatePropertyError {
            throw error
        }
    }
    
    func updatePropertyOption(id: String, text: String, color: String?) async throws {
        lastUpdatePropertyOption = (id, text, color)
        if let error = updatePropertyOptionError {
            throw error
        }
    }
    
    func updateProperty(objectId: String, fields: [String: Google_Protobuf_Value]) async throws {
        // Implementation needed
    }
    
    func createProperty(spaceId: String, propertyDetails: PropertyDetails) async throws -> PropertyDetails {
        lastCreateProperty = (spaceId, propertyDetails)
        if let error = createPropertyError {
            throw error
        }
        return propertyDetails
    }
    
    func addProperties(objectId: String, propertiesDetails: [PropertyDetails]) async throws {
        lastAddProperties = (objectId, propertiesDetails)
        if let error = addPropertiesError {
            throw error
        }
    }
    
    func addProperties(objectId: String, propertyKeys: [String]) async throws {
        lastAddProperties = (objectId, propertyKeys)
        if let error = addPropertiesError {
            throw error
        }
    }
    
    func removeProperty(objectId: String, propertyKey: String) async throws {
        lastRemoveProperty = (objectId, propertyKey)
        if let error = removePropertyError {
            throw error
        }
    }
    
    func removeProperties(objectId: String, propertyKeys: [String]) async throws {
        lastRemoveProperties = (objectId, propertyKeys)
        if let error = removePropertiesError {
            throw error
        }
    }
    
    func addPropertyOption(spaceId: String, propertyKey: String, optionText: String, color: String?) async throws -> String? {
        lastAddPropertyOption = (spaceId, propertyKey, optionText, color)
        if let error = addPropertyOptionError {
            throw error
        }
        return nil
    }
    
    func removePropertyOptions(ids: [String]) async throws {
        lastRemovePropertyOptions = ids
        if let error = removePropertyOptionsError {
            throw error
        }
    }
    
    func updateTypeProperties(
        typeId: String,
        dataviewId: String,
        recommendedProperties: [PropertyDetails],
        recommendedFeaturedProperties: [PropertyDetails],
        recommendedHiddenProperties: [PropertyDetails]
    ) async throws {
        lastUpdateTypeProperties = (typeId, dataviewId, recommendedProperties, recommendedFeaturedProperties, recommendedHiddenProperties)
        if let error = updateTypePropertiesError {
            throw error
        }
    }
    
    func getConflictPropertiesForType(typeId: String, spaceId: String) async throws -> [String] {
        lastGetConflictPropertiesForType = (typeId, spaceId)
        if let error = getConflictPropertiesForTypeError {
            throw error
        }
        return []
    }
    
    func setFeaturedProperty(objectId: String, featuredPropertyIds: [String]) async throws {
        lastSetFeaturedProperty = (objectId, featuredPropertyIds)
        if let error = setFeaturedPropertyError {
            throw error
        }
    }
    
    func toggleDescription(objectId: String, isOn: Bool) async throws {
        lastToggleDescription = (objectId, isOn)
        if let error = toggleDescriptionError {
            throw error
        }
    }
    

    // Convenience method to reset all last call data
    func reset() {
        lastUpdateProperty = nil
        lastUpdatePropertyOption = nil
        lastCreateProperty = nil
        lastAddProperties = nil
        lastRemoveProperty = nil
        lastRemoveProperties = nil
        lastAddPropertyOption = nil
        lastRemovePropertyOptions = nil
        lastUpdateTypeProperties = nil
        lastGetConflictPropertiesForType = nil
        lastSetFeaturedProperty = nil
        lastToggleDescription = nil
    }
}
