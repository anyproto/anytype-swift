import Foundation
import ProtobufMessages
import SwiftProtobuf

enum RelationServiceError: Error {
    case unableToCreateRelationFromObject
}

final class RelationsService: RelationsServiceProtocol {
    
    // MARK: - RelationsServiceProtocol
    
    public func addFeaturedRelation(objectId: String, relationKey: String) async throws {
        try await ClientCommands.objectRelationAddFeatured(.with {
            $0.contextID = objectId
            $0.relations = [relationKey]
        }).invoke()
    }
    
    public func removeFeaturedRelation(objectId: String, relationKey: String) async throws {
        try await ClientCommands.objectRelationRemoveFeatured(.with {
            $0.contextID = objectId
            $0.relations = [relationKey]
        }).invoke()
    }
    
    public func updateRelation(objectId: String, relationKey: String, value: Google_Protobuf_Value) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = objectId
            $0.details = [
                Anytype_Rpc.Object.SetDetails.Detail.with {
                    $0.key = relationKey
                    $0.value = value
                }
            ]
        }).invoke()
    }
    
    public func updateRelationOption(id: String, text: String, color: String?) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = id
            $0.details = .builder {
                Anytype_Rpc.Object.SetDetails.Detail.with {
                    $0.key = BundledRelationKey.name.rawValue
                    $0.value = text.protobufValue
                }
                if let color {
                    Anytype_Rpc.Object.SetDetails.Detail.with {
                        $0.key = BundledRelationKey.relationOptionColor.rawValue
                        $0.value = color.protobufValue
                    }
                }
            }
        }).invoke()
    }

    public func createRelation(spaceId: String, relationDetails: RelationDetails) async throws -> RelationDetails {
        let result = try await ClientCommands.objectCreateRelation(.with {
            $0.details = relationDetails.asCreateMiddleware
            $0.spaceID = spaceId
        }).invoke()
        
        guard let objectDetails = try? ObjectDetails(protobufStruct: result.details) else {
            throw RelationServiceError.unableToCreateRelationFromObject
        }
              
        return RelationDetails(objectDetails: objectDetails)
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
        _ = try await ClientCommands.objectRelationDelete(.with {
            $0.contextID = objectId
            $0.relationKeys = [relationKey]
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
}
