import BlocksModels
import ProtobufMessages

struct ObjectTypesParser {
    
    func objectTypes(from response: Anytype_Rpc.ObjectType.List.Response) -> [ObjectTypeData] {
        response.objectTypes.map { ObjectTypeData.create(objectType: $0) }
    }
}
