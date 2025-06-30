import Foundation
import ProtobufMessages

extension BlockProperty {
    func handleSetRelation(data: Anytype_Event.Block.Set.Relation) -> Self{
        var newData = self
        
        if data.hasKey {
            newData.key = data.key.value
        }
        
        return newData
    }
}
