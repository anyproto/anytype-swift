import Foundation
import ProtobufMessages
import SwiftProtobuf

enum RelationServiceError: Error {
    case unableToCreateRelationFromObject
}

final class RelationsService: RelationsServiceProtocol {
    
    // MARK: - RelationsServiceProtocol
    
    func setFeaturedRelation(objectId: String, featuredRelationIds: [String]) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = objectId
            $0.details = [
                Anytype_Model_Detail.with {
                    $0.key = BundledRelationKey.featuredRelations.rawValue
                    $0.value = featuredRelationIds.protobufValue
                }
            ]
        }).invoke()
    }
    
    public func updateRelation(objectId: String, relationKey: String, value: Google_Protobuf_Value) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = objectId
            $0.details = [
                Anytype_Model_Detail.with {
                    $0.key = relationKey
                    $0.value = value
                }
            ]
        }).invoke()
    }
    
    func updateRelation(objectId: String, fields: [String: Google_Protobuf_Value]) async throws {
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
    
    public func updateRelationOption(id: String, text: String, color: String?) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = id
            $0.details = .builder {
                Anytype_Model_Detail.with {
                    $0.key = BundledRelationKey.name.rawValue
                    $0.value = text.protobufValue
                }
                if let color {
                    Anytype_Model_Detail.with {
                        $0.key = BundledRelationKey.relationOptionColor.rawValue
                        $0.value = color.protobufValue
                    }
                }
            }
        }).invoke()
    }

    public func createRelation(spaceId: String, relationDetails: RelationDetails) async throws -> RelationDetails {
        let result = try await ClientCommands.objectCreateRelation(.with {
            $0.details = relationDetails.asMiddleware
            $0.spaceID = spaceId
        }).invoke()
        
        guard let objectDetails = try? ObjectDetails(protobufStruct: result.details) else {
            throw RelationServiceError.unableToCreateRelationFromObject
        }
              
        return RelationDetails(details: objectDetails)
    }

    public func addRelations(objectId: String, relationsDetails: [RelationDetails]) async throws {
        try await addRelations(objectId: objectId, relationKeys: relationsDetails.map(\.key))
    }

    public func addRelations(objectId: String, relationKeys: [String]) async throws {
        try await ClientCommands.objectRelationAdd(.with {
            $0.contextID = objectId
            $0.relationKeys = relationKeys
        }).invoke()
    }
    
    public func removeRelation(objectId: String, relationKey: String) async throws {
        try await removeRelations(objectId: objectId, relationKeys: [relationKey])
    }
    
    public func removeRelations(objectId: String, relationKeys: [String]) async throws {
        _ = try await ClientCommands.objectRelationDelete(.with {
            $0.contextID = objectId
            $0.relationKeys = relationKeys
        }).invoke()
    }
    
    public func addRelationOption(spaceId: String, relationKey: String, optionText: String, color: String?) async throws -> String? {
        let color = color ?? MiddlewareColor.allCases.randomElement()?.rawValue ?? MiddlewareColor.default.rawValue
        
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.name.rawValue: optionText.protobufValue,
                BundledRelationKey.relationKey.rawValue: relationKey.protobufValue,
                BundledRelationKey.relationOptionColor.rawValue: color.protobufValue
            ]
        )
        
        let optionResult = try? await ClientCommands.objectCreateRelationOption(.with {
            $0.details = details
            $0.spaceID = spaceId
        }).invoke()
        
        return optionResult?.objectID
    }
    
    public func removeRelationOptions(ids: [String]) async throws {
        try await ClientCommands.relationListRemoveOption(.with {
            $0.optionIds = ids
        }).invoke()
    }
    
    // MARK: - New api
    // Updating both relations in type and dataview to preserve integrity between them
    func updateTypeRelations(
        typeId: String,
        dataviewId: String,
        recommendedRelations: [RelationDetails],
        recommendedFeaturedRelations: [RelationDetails],
        recommendedHiddenRelations: [RelationDetails]
    ) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = typeId
            $0.details = [
                Anytype_Model_Detail.with {
                    $0.key = BundledRelationKey.recommendedRelations.rawValue
                    $0.value = recommendedRelations.map(\.id).protobufValue
                },
                Anytype_Model_Detail.with {
                    $0.key = BundledRelationKey.recommendedFeaturedRelations.rawValue
                    $0.value = recommendedFeaturedRelations.map(\.id).protobufValue
                },
                Anytype_Model_Detail.with {
                    $0.key = BundledRelationKey.recommendedHiddenRelations.rawValue
                    $0.value = recommendedHiddenRelations.map(\.id).protobufValue
                }
            ]
        }).invoke()
        
        let compoundRelations = recommendedFeaturedRelations + recommendedRelations + recommendedHiddenRelations
        let relationKeys = NSOrderedSet(array: compoundRelations.map(\.key)).array as! [String]
        try await ClientCommands.blockDataviewRelationSet(.with {
            $0.contextID = typeId
            $0.blockID = dataviewId
            $0.relationKeys = relationKeys
        }).invoke()
    }
    
    func getConflictRelationsForType(typeId: String, spaceId: String) async throws -> [String] {
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
                $0.relations = [BundledRelationKey.description.rawValue]
            }).invoke()
        } else {
            try await ClientCommands.objectRelationRemoveFeatured(.with {
                $0.contextID = objectId
                $0.relations = [BundledRelationKey.description.rawValue]
            }).invoke()
        }
    }
    
}
