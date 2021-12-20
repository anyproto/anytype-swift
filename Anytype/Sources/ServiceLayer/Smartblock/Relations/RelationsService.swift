import Foundation
import ProtobufMessages
import BlocksModels

final class RelationsService {
    
    private let objectId: String
        
    init(objectId: String) {
        self.objectId = objectId
    }
    
}

extension RelationsService: RelationsServiceProtocol {
    
    func addFeaturedRelation(relationKey: String) {
        Anytype_Rpc.Object.FeaturedRelation.Add.Service.invoke(
            contextID: objectId,
            relations: [relationKey]
        ).map { EventsBunch(event: $0.event) }
        .getValue()?
        .send()
    }
    
    func removeFeaturedRelation(relationKey: String) {
        Anytype_Rpc.Object.FeaturedRelation.Remove.Service.invoke(
            contextID: objectId,
            relations: [relationKey]
        ).map { EventsBunch(event: $0.event) }
        .getValue()?
        .send()
    }
    
    func removeRelation(relationKey: String) {
        Anytype_Rpc.Object.RelationDelete.Service.invoke(
            contextID: objectId,
            relationKey: relationKey
        ).map { EventsBunch(event: $0.event) }
        .getValue()?
        .send()
    }
    
    func addRelationOption(relationKey: String, optionText: String) -> String? {
        let response = Anytype_Rpc.Object.RelationOptionAdd.Service.invoke(
            contextID: objectId,
            relationKey: relationKey,
            option: Anytype_Model_Relation.Option(
                id: "",
                text: optionText,
                color: MiddlewareColor.allCases.randomElement()?.rawValue ?? MiddlewareColor.default.rawValue,
                scope: .local
            )
        ).getValue()
        
        guard let response = response else { return nil }
        
        EventsBunch(event: response.event).send()
        
        return response.option.id
    }

    func availableRelations() -> [RelationMetadata]? {
        let response = Anytype_Rpc.Object.RelationListAvailable.Service.invoke(contextID: objectId)
            .getValue()

        guard let response = response else { return nil }

        return response.relations.map { RelationMetadata(middlewareRelation: $0) }
    }
    
}
