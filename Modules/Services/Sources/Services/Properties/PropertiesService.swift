import Foundation
import ProtobufMessages
import SwiftProtobuf

enum PropertyServiceError: Error {
    case unableToCreateRelationFromObject
}

final class PropertiesService: PropertiesServiceProtocol {
    
    // MARK: - PropertiesServiceProtocol
    
    func setFeaturedProperty(objectId: String, featuredPropertyIds: [String]) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = objectId
            $0.details = [
                Anytype_Model_Detail.with {
                    $0.key = BundledPropertyKey.featuredRelations.rawValue
                    $0.value = featuredPropertyIds.protobufValue
                }
            ]
        }).invoke()
    }
    
    public func updateProperty(objectId: String, propertyKey: String, value: Google_Protobuf_Value) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = objectId
            $0.details = [
                Anytype_Model_Detail.with {
                    $0.key = propertyKey
                    $0.value = value
                }
            ]
        }).invoke()
    }
    
    func updateProperty(objectId: String, fields: [String: Google_Protobuf_Value]) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = objectId
            $0.details = fields.map { key, value in
                Anytype_Model_Detail.with {
                    $0.key = key
                    $0.value = value
                }
            }
        }).invoke()
    }
    
    public func updatePropertyOption(id: String, text: String, color: String?) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = id
            $0.details = .builder {
                Anytype_Model_Detail.with {
                    $0.key = BundledPropertyKey.name.rawValue
                    $0.value = text.protobufValue
                }
                if let color {
                    Anytype_Model_Detail.with {
                        $0.key = BundledPropertyKey.relationOptionColor.rawValue
                        $0.value = color.protobufValue
                    }
                }
            }
        }).invoke()
    }

    public func createProperty(spaceId: String, propertyDetails: RelationDetails) async throws -> RelationDetails {
        let result = try await ClientCommands.objectCreateRelation(.with {
            $0.details = propertyDetails.asMiddleware
            $0.spaceID = spaceId
        }).invoke()
        
        guard let objectDetails = try? ObjectDetails(protobufStruct: result.details) else {
            throw PropertyServiceError.unableToCreateRelationFromObject
        }
              
        return RelationDetails(details: objectDetails)
    }

    public func addProperties(objectId: String, propertiesDetails: [RelationDetails]) async throws {
        try await addProperties(objectId: objectId, propertyKeys: propertiesDetails.map(\.key))
    }

    public func addProperties(objectId: String, propertyKeys: [String]) async throws {
        try await ClientCommands.objectRelationAdd(.with {
            $0.contextID = objectId
            $0.relationKeys = propertyKeys
        }).invoke()
    }
    
    public func removeProperty(objectId: String, propertyKey: String) async throws {
        try await removeProperties(objectId: objectId, propertyKeys: [propertyKey])
    }
    
    public func removeProperties(objectId: String, propertyKeys: [String]) async throws {
        _ = try await ClientCommands.objectRelationDelete(.with {
            $0.contextID = objectId
            $0.relationKeys = propertyKeys
        }).invoke()
    }
    
    public func addPropertyOption(spaceId: String, propertyKey: String, optionText: String, color: String?) async throws -> String? {
        let color = color ?? MiddlewareColor.allCases.randomElement()?.rawValue ?? MiddlewareColor.default.rawValue
        
        let details = Google_Protobuf_Struct(
            fields: [
                BundledPropertyKey.name.rawValue: optionText.protobufValue,
                BundledPropertyKey.relationKey.rawValue: propertyKey.protobufValue,
                BundledPropertyKey.relationOptionColor.rawValue: color.protobufValue
            ]
        )
        
        let optionResult = try? await ClientCommands.objectCreateRelationOption(.with {
            $0.details = details
            $0.spaceID = spaceId
        }).invoke()
        
        return optionResult?.objectID
    }
    
    public func removePropertyOptions(ids: [String]) async throws {
        try await ClientCommands.relationListRemoveOption(.with {
            $0.optionIds = ids
        }).invoke()
    }
    
    // MARK: - New api
    // Updating both relations in type and dataview to preserve integrity between them
    func updateTypeProperties(
        typeId: String,
        dataviewId: String,
        recommendedProperties: [RelationDetails],
        recommendedFeaturedProperties: [RelationDetails],
        recommendedHiddenProperties: [RelationDetails]
    ) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = typeId
            $0.details = [
                Anytype_Model_Detail.with {
                    $0.key = BundledPropertyKey.recommendedRelations.rawValue
                    $0.value = recommendedProperties.map(\.id).protobufValue
                },
                Anytype_Model_Detail.with {
                    $0.key = BundledPropertyKey.recommendedFeaturedRelations.rawValue
                    $0.value = recommendedFeaturedProperties.map(\.id).protobufValue
                },
                Anytype_Model_Detail.with {
                    $0.key = BundledPropertyKey.recommendedHiddenRelations.rawValue
                    $0.value = recommendedHiddenProperties.map(\.id).protobufValue
                }
            ]
        }).invoke()
        
        let compoundRelationsKeys = (recommendedFeaturedProperties + recommendedProperties + recommendedHiddenProperties).map(\.key)
        let descriptionKey = BundledPropertyKey.description.rawValue // Show description in dataview relations list
        let nameKey = BundledPropertyKey.name.rawValue // Show name in dataview relations list
        let dataviewKeys = compoundRelationsKeys + [nameKey, descriptionKey]
        
        let uniqueDataviewKeys = NSOrderedSet(array: dataviewKeys).array as! [String]
        try await ClientCommands.blockDataviewRelationSet(.with {
            $0.contextID = typeId
            $0.blockID = dataviewId
            $0.relationKeys = uniqueDataviewKeys
        }).invoke()
    }
    
    func getConflictPropertiesForType(typeId: String, spaceId: String) async throws -> [String] {
        try await ClientCommands.objectTypeListConflictingRelations(.with {
            $0.spaceID = spaceId
            $0.typeObjectID = typeId
        }).invoke().relationIds
    }
    
    // Only one relation that use legacy api is description. It's visibility is stored on per object basis.
    // All other relations visibility are stored in type now
    public func toggleDescription(objectId: String, isOn: Bool) async throws {
        if isOn {
            try await ClientCommands.objectRelationAddFeatured(.with {
                $0.contextID = objectId
                $0.relations = [BundledPropertyKey.description.rawValue]
            }).invoke()
        } else {
            try await ClientCommands.objectRelationRemoveFeatured(.with {
                $0.contextID = objectId
                $0.relations = [BundledPropertyKey.description.rawValue]
            }).invoke()
        }
    }
    
}
