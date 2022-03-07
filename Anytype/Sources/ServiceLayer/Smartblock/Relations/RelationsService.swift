import Foundation
import ProtobufMessages
import BlocksModels
import SwiftProtobuf
import Amplitude

final class RelationsService {
    
    private let objectId: String
        
    init(objectId: String) {
        self.objectId = objectId
    }
    
}

extension RelationsService: RelationsServiceProtocol {
    
    func addFeaturedRelation(relationKey: String) {
        Amplitude.instance().logEvent(AmplitudeEventsName.addFeatureRelation)

        Anytype_Rpc.Object.FeaturedRelation.Add.Service.invoke(
            contextID: objectId,
            relations: [relationKey]
        ).map { EventsBunch(event: $0.event) }
        .getValue(domain: .relationsService)?
        .send()
    }
    
    func removeFeaturedRelation(relationKey: String) {
        Amplitude.instance().logEvent(AmplitudeEventsName.removeFeatureRelation)

        Anytype_Rpc.Object.FeaturedRelation.Remove.Service.invoke(
            contextID: objectId,
            relations: [relationKey]
        ).map { EventsBunch(event: $0.event) }
        .getValue(domain: .relationsService)?
        .send()
    }
    
    func updateRelation(relationKey: String, value: Google_Protobuf_Value) {
        Anytype_Rpc.Block.Set.Details.Service.invoke(
            contextID: objectId,
            details: [
                Anytype_Rpc.Block.Set.Details.Detail(
                    key: relationKey,
                    value: value
                )
            ]
        )
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .relationsService)?
            .send()
        Amplitude.instance().logEvent(AmplitudeEventsName.changeRelationValue)
    }

    func createRelation(relation: RelationMetadata) -> RelationMetadata? {
        addRelation(relation: relation, isNew: true)
    }

    func addRelation(relation: RelationMetadata) -> RelationMetadata? {
        addRelation(relation: relation, isNew: false)
    }

    private func addRelation(relation: RelationMetadata, isNew: Bool) -> RelationMetadata? {
        let response = Anytype_Rpc.Object.RelationAdd.Service
            .invoke(contextID: objectId, relation: relation.middlewareModel)
            .getValue(domain: .relationsService)

        guard let response = response else { return nil }

        EventsBunch(event: response.event).send()

        Amplitude.instance().logAddRelation(format: relation.format, isNew: isNew)

        return RelationMetadata(middlewareRelation: response.relation)
    }
    
    func removeRelation(relationKey: String) {
        Anytype_Rpc.Object.RelationDelete.Service
            .invoke(contextID: objectId, relationKey: relationKey)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .relationsService)?
            .send()
        
        Amplitude.instance().logEvent(AmplitudeEventsName.deleteRelation)
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
            let response = Anytype_Rpc.Object.RelationOptionAdd.Service.invoke(
                contextID: objectId,
                relationKey: relationKey,
                option: option
            )
                .getValue(domain: .relationsService)
            
            guard let response = response else { return nil }
            
            EventsBunch(event: response.event).send()
            
            return response.option.id
        case .dataview(let contextId):
            let response = Anytype_Rpc.Block.Dataview.RecordRelationOptionAdd.Service.invoke(
                contextID: contextId,
                blockID: SetConstants.dataviewBlockId,
                relationKey: relationKey,
                option: option,
                recordID: objectId
            ).getValue(domain: .relationsService)
            
            guard let response = response else { return nil }
            
            EventsBunch(event: response.event).send()
            
            return response.option.id
        }
    }

    func availableRelations() -> [RelationMetadata]? {
        let relations = Anytype_Rpc.Object.RelationListAvailable.Service
            .invoke(contextID: objectId)
            .map { $0.relations }
            .getValue(domain: .relationsService)
        
        return relations?.map { RelationMetadata(middlewareRelation: $0) }
    }
    
}
