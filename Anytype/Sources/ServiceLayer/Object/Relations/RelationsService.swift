import Foundation
import ProtobufMessages
import BlocksModels
import SwiftProtobuf

final class RelationsService {
    
    private let objectId: String
        
    init(objectId: String) {
        self.objectId = objectId
    }
    
}

extension RelationsService: RelationsServiceProtocol {
    
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

    func createRelation(relation: RelationMetadata) -> RelationMetadata? {
        addRelation(relation: relation, isNew: true)
    }

    func addRelation(relation: RelationMetadata) -> RelationMetadata? {
        addRelation(relation: relation, isNew: false)
    }

    private func addRelation(relation: RelationMetadata, isNew: Bool) -> RelationMetadata? {
        #warning("Fix me")
        return nil
//        let response = Anytype_Rpc.ObjectRelation.Add.Service
//            .invoke(contextID: objectId, relation: relation.asMiddleware)
//            .getValue(domain: .relationsService)
//
//        guard let response = response else { return nil }
//
//        EventsBunch(event: response.event).send()
//
//        return RelationMetadata(middlewareRelation: response.relation)
    }
    
    func removeRelation(relationKey: String) {
        #warning("Fix me")
//        Anytype_Rpc.ObjectRelation.Delete.Service
//            .invoke(contextID: objectId, relationKey: relationKey)
//            .map { EventsBunch(event: $0.event) }
//            .getValue(domain: .relationsService)?
//            .send()
//
//        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.deleteRelation)
    }
    
    func addRelationOption(source: RelationSource, relationKey: String, optionText: String) -> String? {
        let option = Anytype_Model_Relation.Option(
            id: "",
            text: optionText,
            color: MiddlewareColor.allCases.randomElement()?.rawValue ?? MiddlewareColor.default.rawValue,
            scope: .local
        )
        
        switch source {
        case .object:
            #warning("Fix me")
            return nil
//            let response = Anytype_Rpc.ObjectRelationOption.Add.Service.invoke(
//                contextID: objectId,
//                relationKey: relationKey,
//                option: option
//            )
//                .getValue(domain: .relationsService)
//
//            guard let response = response else { return nil }
//
//            EventsBunch(event: response.event).send()
//
//            return response.option.id
        case .dataview(let contextId):
        #warning("Fix me")
            return nil
//            let response = Anytype_Rpc.BlockDataviewRecord.RelationOption.Add.Service.invoke(
//                contextID: contextId,
//                blockID: SetConstants.dataviewBlockId,
//                relationKey: relationKey,
//                option: option,
//                recordID: objectId
//            ).getValue(domain: .relationsService)
//
//            guard let response = response else { return nil }
//
//            EventsBunch(event: response.event).send()
//
//            return response.option.id
        }
    }

    func availableRelations() -> [RelationMetadata]? {
        let relations = Anytype_Rpc.ObjectRelation.ListAvailable.Service
            .invoke(contextID: objectId)
            .map { $0.relations }
            .getValue(domain: .relationsService)
        
        return relations?.map { RelationMetadata(middlewareRelation: $0) }
    }
    
}
