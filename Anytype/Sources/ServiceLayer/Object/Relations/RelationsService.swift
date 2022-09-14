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

        Anytype_Rpc.ObjectRelation.AddFeatured.Service.invoke(
            contextID: objectId,
            relations: [relationKey]
        ).map { EventsBunch(event: $0.event) }
        .getValue(domain: .relationsService)?
        .send()
    }
    
    func removeFeaturedRelation(relationKey: String) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeFeatureRelation)
        Anytype_Rpc.ObjectRelation.RemoveFeatured.Service.invoke(
            contextID: objectId,
            relations: [relationKey]
        ).map { EventsBunch(event: $0.event) }
        .getValue(domain: .relationsService)?
        .send()
    }
    
    func updateRelation(relationKey: String, value: Google_Protobuf_Value) {
        Anytype_Rpc.Object.SetDetails.Service.invoke(
            contextID: objectId,
            details: [
                Anytype_Rpc.Object.SetDetails.Detail(
                    key: relationKey,
                    value: value
                )
            ]
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .relationsService)?
            .send()
    }

    func createRelation(relationDetails: RelationDetails) -> Bool {
        let result = Anytype_Rpc.Object.CreateRelation.Service
            .invocation(details: relationDetails.asCreateMiddleware)
            .invoke()
            .getValue(domain: .relationsService)
        
        guard let result = result else { return false }
        
        return addRelation(relationId: result.objectID)
    }

    func addRelation(relationDetails: RelationDetails) -> Bool {
        return addRelation(relationId: relationDetails.id)
    }

    private func addRelation(relationId: String) -> Bool {
        let events = Anytype_Rpc.ObjectRelation.Add.Service
            .invocation(contextID: objectId, relationIds: [relationId])
            .invoke()
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .relationsService)
            
        events?.send()
        
        return events.isNotNil
    }
    
    func removeRelation(relationId: String) {
        Anytype_Rpc.ObjectRelation.Delete.Service
            .invocation(contextID: objectId, relationID: relationId)
            .invoke()
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .relationsService)?
            .send()

        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.deleteRelation)
    }
    
    func addRelationOption(source: RelationSource, relationKey: String, optionText: String) -> String? {
        let color = MiddlewareColor.allCases.randomElement()?.rawValue ?? MiddlewareColor.default.rawValue
        
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.relationOptionText.rawValue: optionText.protobufValue,
                BundledRelationKey.relationKey.rawValue: relationKey.protobufValue,
                BundledRelationKey.relationOptionColor.rawValue: color.protobufValue
            ]
        )
        
        let optionResult = Anytype_Rpc.Object.CreateRelationOption.Service.invocation(details: details)
            .invoke()
            .getValue(domain: .relationsService)
        
        return optionResult?.objectID
    }

    func availableRelations() -> [RelationDetails] {
        relationDetailsStorage.relationsDetails()
    }
}
