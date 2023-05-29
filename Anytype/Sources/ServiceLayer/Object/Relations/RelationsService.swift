import Foundation
import ProtobufMessages
import BlocksModels
import SwiftProtobuf

final class RelationsService: RelationsServiceProtocol {
    
    private let relationDetailsStorage = ServiceLocator.shared.relationDetailsStorage()
    private let objectId: String
        
    init(objectId: String) {
        self.objectId = objectId
    }
    
    // MARK: - RelationsServiceProtocol
    
    func addFeaturedRelation(relationKey: String) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.addFeatureRelation)
        _ = try? ClientCommands.objectRelationAddFeatured(.with {
            $0.contextID = objectId
            $0.relations = [relationKey]
        }).invoke(errorDomain: .relationsService)
    }
    
    func removeFeaturedRelation(relationKey: String) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeFeatureRelation)
        _ = try? ClientCommands.objectRelationRemoveFeatured(.with {
            $0.contextID = objectId
            $0.relations = [relationKey]
        }).invoke(errorDomain: .relationsService)
    }
    
    func updateRelation(relationKey: String, value: Google_Protobuf_Value) {
        _ = try? ClientCommands.objectSetDetails(.with {
            $0.contextID = objectId
            $0.details = [
                Anytype_Rpc.Object.SetDetails.Detail.with {
                    $0.key = relationKey
                    $0.value = value
                }
            ]
        }).invoke(errorDomain: .relationsService)
    }

    func createRelation(relationDetails: RelationDetails) -> RelationDetails? {
        let result = try? ClientCommands.objectCreateRelation(.with {
            $0.details = relationDetails.asCreateMiddleware
        }).invoke(errorDomain: .relationsService)
        
        guard let result = result,
              addRelations(relationKeys: [result.key]),
              let objectDetails = ObjectDetails(protobufStruct: result.details)
            else { return nil }
        
        return RelationDetails(objectDetails: objectDetails)
    }

    func addRelations(relationsDetails: [RelationDetails]) -> Bool {
        return addRelations(relationKeys: relationsDetails.map(\.key))
    }

    func addRelations(relationKeys: [String]) -> Bool {
        let result = try? ClientCommands.objectRelationAdd(.with {
            $0.contextID = objectId
            $0.relationKeys = relationKeys
        }).invoke(errorDomain: .relationsService)
        
        return result.isNotNil
    }
    
    func removeRelation(relationKey: String) {
        _ = try? ClientCommands.objectRelationDelete(.with {
            $0.contextID = objectId
            $0.relationKeys = [relationKey]
        }).invoke(errorDomain: .relationsService)
        
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.deleteRelation)
    }
    
    func addRelationOption(relationKey: String, optionText: String) -> String? {
        let color = MiddlewareColor.allCases.randomElement()?.rawValue ?? MiddlewareColor.default.rawValue
        
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.name.rawValue: optionText.protobufValue,
                BundledRelationKey.relationKey.rawValue: relationKey.protobufValue,
                BundledRelationKey.relationOptionColor.rawValue: color.protobufValue
            ]
        )
        
        let optionResult = try? ClientCommands.objectCreateRelationOption(.with {
            $0.details = details
        }).invoke(errorDomain: .relationsService)
        
        return optionResult?.objectID
    }

    func availableRelations() -> [RelationDetails] {
        relationDetailsStorage.relationsDetails()
    }
}
