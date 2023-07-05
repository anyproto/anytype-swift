import Foundation
import ProtobufMessages
import Services
import SwiftProtobuf

enum RelationServiceError: Error {
    case unableToCreateRelationFromObject
}

final class RelationsService: RelationsServiceProtocol {
    
    private let relationDetailsStorage = ServiceLocator.shared.relationDetailsStorage()
    private let objectId: String
        
    init(objectId: String) {
        self.objectId = objectId
    }
    
    // MARK: - RelationsServiceProtocol
    
    func addFeaturedRelation(relationKey: String) async throws {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.addFeatureRelation)
        try await ClientCommands.objectRelationAddFeatured(.with {
            $0.contextID = objectId
            $0.relations = [relationKey]
        }).invoke()
    }
    
    func removeFeaturedRelation(relationKey: String) async throws {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeFeatureRelation)
        try await ClientCommands.objectRelationRemoveFeatured(.with {
            $0.contextID = objectId
            $0.relations = [relationKey]
        }).invoke()
    }
    
    func updateRelation(relationKey: String, value: Google_Protobuf_Value) async throws {
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

    func createRelation(relationDetails: RelationDetails) async throws -> RelationDetails? {
        let result = try await ClientCommands.objectCreateRelation(.with {
            $0.details = relationDetails.asCreateMiddleware
        }).invoke()
        
        try await addRelations(relationKeys: [result.key])
        guard let objectDetails = try? ObjectDetails(protobufStruct: result.details) else {
            throw RelationServiceError.unableToCreateRelationFromObject
        }
              
        return RelationDetails(objectDetails: objectDetails)
    }

    func addRelations(relationsDetails: [RelationDetails]) async throws {
        try await addRelations(relationKeys: relationsDetails.map(\.key))
    }

    func addRelations(relationKeys: [String]) async throws {
        try await ClientCommands.objectRelationAdd(.with {
            $0.contextID = objectId
            $0.relationKeys = relationKeys
        }).invoke()
    }
    
    func removeRelation(relationKey: String) {
        _ = try? ClientCommands.objectRelationDelete(.with {
            $0.contextID = objectId
            $0.relationKeys = [relationKey]
        }).invoke()
        
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.deleteRelation)
    }
    
    func addRelationOption(relationKey: String, optionText: String) async throws -> String? {
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

    func availableRelations() -> [RelationDetails] {
        relationDetailsStorage.relationsDetails()
    }
}
