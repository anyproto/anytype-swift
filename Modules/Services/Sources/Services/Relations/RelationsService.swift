import Foundation
import ProtobufMessages
import SwiftProtobuf

enum RelationServiceError: Error {
    case unableToCreateRelationFromObject
}

public final class RelationsService: RelationsServiceProtocol {
    
    private let objectId: String
        
    public init(objectId: String) {
        self.objectId = objectId
    }
    
    // MARK: - RelationsServiceProtocol
    
    public func addFeaturedRelation(relationKey: String) async throws {
        try await ClientCommands.objectRelationAddFeatured(.with {
            $0.contextID = objectId
            $0.relations = [relationKey]
        }).invoke()
    }
    
    public func removeFeaturedRelation(relationKey: String) async throws {
        try await ClientCommands.objectRelationRemoveFeatured(.with {
            $0.contextID = objectId
            $0.relations = [relationKey]
        }).invoke()
    }
    
    public func updateRelation(relationKey: String, value: Google_Protobuf_Value) async throws {
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

    public func createRelation(relationDetails: RelationDetails) async throws -> RelationDetails? {
        let result = try await ClientCommands.objectCreateRelation(.with {
            $0.details = relationDetails.asCreateMiddleware
        }).invoke()
        
        try await addRelations(relationKeys: [result.key])
        guard let objectDetails = try? ObjectDetails(protobufStruct: result.details) else {
            throw RelationServiceError.unableToCreateRelationFromObject
        }
              
        return RelationDetails(objectDetails: objectDetails)
    }

    public func addRelations(relationsDetails: [RelationDetails]) async throws {
        try await addRelations(relationKeys: relationsDetails.map(\.key))
    }

    public func addRelations(relationKeys: [String]) async throws {
        try await ClientCommands.objectRelationAdd(.with {
            $0.contextID = objectId
            $0.relationKeys = relationKeys
        }).invoke()
    }
    
    public func removeRelation(relationKey: String) async throws {
        _ = try await ClientCommands.objectRelationDelete(.with {
            $0.contextID = objectId
            $0.relationKeys = [relationKey]
        }).invoke()
    }
    
    public func addRelationOption(relationKey: String, optionText: String) async throws -> String? {
        let color = MiddlewareColor.allCases.randomElement()?.rawValue ?? MiddlewareColor.default.rawValue
        
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.name.rawValue: optionText.protobufValue,
                BundledRelationKey.relationKey.rawValue: relationKey.protobufValue,
                BundledRelationKey.relationOptionColor.rawValue: color.protobufValue
            ]
        )
        
        let optionResult = try? await ClientCommands.objectCreateRelationOption(.with {
            $0.details = details
        }).invoke()
        
        return optionResult?.objectID
    }
}
