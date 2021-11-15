import Foundation
import ProtobufMessages
import BlocksModels

final class RelationsService: RelationsServiceProtocol {
    
    func addFeaturedRelations(objectId: BlockId, relationIds: [String]) {
        Anytype_Rpc.Object.FeaturedRelation.Add.Service.invoke(
            contextID: objectId,
            relations: relationIds
        ).map { EventsBunch(event: $0.event) }
        .getValue()?
        .send()
    }
    
    func removeFeaturedRelations(objectId: BlockId, relationIds: [String]) {
        Anytype_Rpc.Object.FeaturedRelation.Remove.Service.invoke(
            contextID: objectId,
            relations: relationIds
        ).map { EventsBunch(event: $0.event) }
        .getValue()?
        .send()
    }
    
}
