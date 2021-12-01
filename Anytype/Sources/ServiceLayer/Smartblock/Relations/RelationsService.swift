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
    
}
