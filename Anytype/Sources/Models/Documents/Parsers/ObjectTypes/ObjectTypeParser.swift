import BlocksModels
import ProtobufMessages

struct ObjectTypesParser {
    
    func objectTypes(from response: Anytype_Rpc.ObjectType.List.Response) -> [ObjectType] {
        response.objectTypes.map { objectType(from: $0) }
    }
    
    private func objectType(from objectType: Anytype_Model_ObjectType) -> ObjectType {
        ObjectType(name: objectType.name,
                   url: objectType.url,
                   emoji: objectType.iconEmoji,
                   description: objectType.description_p)
    }
}
